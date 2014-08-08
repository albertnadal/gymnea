//
//  CatalogWebServiceClient.m
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GymneaWSClient.h"
#import "Reachability.h"
#import "GEAAuthentication.h"
#import "GEAAuthenticationKeychainStore.h"

static const NSString *kWSDomain = @"athlete.gymnea.com";

@interface GymneaWSClient ()
{
    BOOL internetIsReachable;
    Reachability* reach;
}

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, retain) Reachability *reach;
@property (nonatomic) BOOL internetIsReachable;

typedef void(^responseCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *responseCookies);

- (void) performAsyncRequest:(NSString *)path
              withDictionary:(NSDictionary *)values
          withAuthentication:(GEAAuthentication *)auth
         withCompletionBlock:(responseCompletionBlock)completionBlock;

@end

@implementation GymneaWSClient

@synthesize sessionId;
@synthesize internetIsReachable;
@synthesize reach;


+ (GymneaWSClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    static GymneaWSClient *_instance;

    dispatch_once(&onceToken, ^{
        _instance = [[GymneaWSClient alloc] init];
    });

    return _instance;
}

- (id)init
{
    if(self = [super init])
    {
        self.internetIsReachable = TRUE;
        self.reach = [Reachability reachabilityWithHostname:[NSString stringWithFormat:@"%@", kWSDomain]];

        __weak GymneaWSClient *wsc = self;

        reach.reachableBlock = ^(Reachability*reach)
        {
            wsc.internetIsReachable = TRUE;
        };

        reach.unreachableBlock = ^(Reachability*reach)
        {
            wsc.internetIsReachable = FALSE;
        };

        [reach startNotifier];

        return self;
    }

    return nil;
}

- (void)signInForUsername:(NSString *)username
              andPassword:(NSString *)password
      withCompletionBlock:(signInCompletionBlock)completionBlock
{
    NSString *requestPath = @"/api/auth";

    [self performAsyncRequest:requestPath
               withDictionary:@{@"username" : username, @"password": password}
           withAuthentication:nil
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              UserInfo *userInfo = nil;

              NSLog(@"RESPONSE DATA: %@", responseData);

              GymneaSignInWSClientRequestResponse signInStatus = GymneaSignInWSClientRequestError;

              if(success == GymneaWSClientRequestSuccess) {
                  signInStatus = GymneaSignInWSClientRequestSuccess;

                  if([cookies objectForKey:@"uid"] != nil) {
                      GEAAuthentication *authentication = [[GEAAuthentication alloc] initWithAuthBaseURL:[NSString stringWithFormat:@"%@", kWSDomain]
                                                                                               userEmail:username
                                                                                          clientInfoHash:[cookies objectForKey:@"uid"]
                                                                                               clientKey:[cookies objectForKey:@"ukey"]];

                      GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
                      [keychainStore setAuthentication:authentication forIdentifier:@"gymnea"];
                  }

                  // Insert or update the current UserInfo register in the DB
                  userInfo = [UserInfo updateUserInfoWithEmail:username withDictionary:[responseData objectForKey:@"userInfo"]];

                  // Now we make a fake request to update the session id
                  [self requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) { /* Do nothing */ }];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signInStatus, responseData, userInfo);
              });

    }];
}

- (void)signUpWithForm:(SignUpForm *)signUpForm
   withCompletionBlock:(signUpCompletionBlock)completionBlock
{
    NSString *requestPath = @"/api/signup";
    
    [self performAsyncRequest:requestPath
               withDictionary:@{@"firstname" : signUpForm.firstName,
                                @"lastname": signUpForm.lastName,
                                @"email": signUpForm.emailAddress,
                                @"password": signUpForm.password,
                                @"gender": signUpForm.gender,
                                @"day": [NSNumber numberWithInt:signUpForm.day],
                                @"month": [NSNumber numberWithInt:signUpForm.month],
                                @"year": [NSNumber numberWithInt:signUpForm.year],
                                @"weight": [NSNumber numberWithFloat:signUpForm.weight],
                                @"weightIsMetric": [NSNumber numberWithBool:signUpForm.weightIsMetricUnits],
                                @"centimeters": [NSNumber numberWithInt:signUpForm.heightCentimeters],
                                @"foot": [NSNumber numberWithInt:signUpForm.heightFoot],
                                @"inches": [NSNumber numberWithInt:signUpForm.heightInches],
                                @"heightIsMetric": [NSNumber numberWithBool:signUpForm.heightIsMetricUnits],
                                @"wearTracker": [NSNumber numberWithInt:signUpForm.doYouWearActivityTracker],
                                @"goGym": [NSNumber numberWithInt:signUpForm.doYouGoToGym],
                                @"useVideoconference": [NSNumber numberWithInt:signUpForm.areYouFamiliarWithVideoconference],
                                @"fitnessGoal": [NSNumber numberWithInt:signUpForm.fitnessGoal]}
           withAuthentication:nil
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              GymneaSignUpWSClientRequestResponse signUpStatus = GymneaSignUpWSClientRequestError;
              UserInfo *userInfo = nil;

              if(success == GymneaWSClientRequestSuccess) {
                  signUpStatus = GymneaSignUpWSClientRequestSuccess;
                  userInfo = [[UserInfo alloc] init];

                  // Now we make a fake request to update the session id
                  [self requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) { /* Do nothing */ }];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signUpStatus, responseData, userInfo);
              });

          }];

}

- (void)requestSessionIdWithCompletionBlock:(sessionIdCompletionBlock)completionBlock
{

    if(self.internetIsReachable) {

        NSString *requestPath = @"/api/user/get_user_info";

        GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
        GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

        [self performAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success);
                      }
                  });

              }];

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestError);
            }
        });

    }

}

- (void)requestUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if(self.internetIsReachable) {

        // Retrieve data from web service API

        NSString *requestPath = @"/api/user/get_user_info";

        [self performAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  UserInfo *userInfo = nil;

                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current UserInfo register in the DB
                      userInfo = [UserInfo updateUserInfoWithEmail:[auth userEmail] withDictionary:[responseData objectForKey:@"userInfo"]];
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, responseData, userInfo);
                      }

                  });

              }];

    } else {

        // Retrieve data from DB by using the email address as primary key

        UserInfo *userInfo = [UserInfo getUserInfo:[auth userEmail]];

        GymneaWSClientRequestStatus success = (userInfo == nil) ? GymneaWSClientRequestError : GymneaWSClientRequestSuccess;

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(success, nil, userInfo);
            }
        });

    }
}

- (void)performAsyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth
        withCompletionBlock:(responseCompletionBlock)completionBlock {

    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPShouldHandleCookies:YES];

    if(auth != nil) {
        NSLog(@"uid: %@", auth.clientInfoHash);
        NSLog(@"ukey: %@", auth.clientKey);
        NSLog(@"session id: %@", [[GymneaWSClient sharedInstance] sessionId]);

        NSDictionary *SessionIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"gym_gymnea", NSHTTPCookieName,
                                             [[GymneaWSClient sharedInstance] sessionId], NSHTTPCookieValue,
                                             nil];

        NSHTTPCookie *SessionIDPackagedCookie = [NSHTTPCookie cookieWithProperties:SessionIDCookieProperties];

        NSDictionary *UIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @".gymnea.com", NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"uid", NSHTTPCookieName,
                                    auth.clientInfoHash, NSHTTPCookieValue,
                                    nil];

        NSHTTPCookie *UIDPackagedCookie = [NSHTTPCookie cookieWithProperties:UIDCookieProperties];

        NSDictionary *UKEYCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"ukey", NSHTTPCookieName,
                                             auth.clientKey, NSHTTPCookieValue,
                                             nil];
        
        NSHTTPCookie *UKEYPackagedCookie = [NSHTTPCookie cookieWithProperties:UKEYCookieProperties];

        NSMutableArray *cookiesArray = [[NSMutableArray alloc] initWithObjects:UIDPackagedCookie, UKEYPackagedCookie, nil];
        if(SessionIDPackagedCookie != nil) {
            [cookiesArray addObject:SessionIDPackagedCookie];
        }

        NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
        [request setAllHTTPHeaderFields:cookies];
    }

    NSError *error;
    if(values != nil) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:0 error:&error];
        [request setHTTPBody:postData];
    }

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];


    NSLog(@"REQUEST: %@", [request allHTTPHeaderFields]);
    
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *responseData, NSURLResponse *urlResponse, NSError *error) {

                                                        NSLog(@"response: %@", urlResponse);

                                                        GymneaWSClientRequestStatus success = GymneaWSClientRequestError;
                                                        NSHTTPURLResponse *response = (NSHTTPURLResponse*)urlResponse;

                                                        NSLog(@"HTTP RESPONSE: %@", response);

                                                        NSInteger responseCode = response.statusCode;
                                                        NSDictionary *results = nil;
                                                        if(error == nil && ((responseCode/100)==2))
                                                        {
                                                            if(responseData != nil)
                                                            {
                                                                results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                                                                NSLog(@"JSON RESULTS: %@", results);
                                                                if(results != nil) {
                                                                    success = GymneaWSClientRequestSuccess;
                                                                }
                                                            }
                                                        }

                                                        NSArray *cookiesArray =[[NSArray alloc]init];
                                                        cookiesArray = [NSHTTPCookie
                                                                   cookiesWithResponseHeaderFields:[response allHeaderFields]
                                                                   forURL:[NSURL URLWithString:@""]];

                                                        NSMutableDictionary *cookies = [[NSMutableDictionary alloc] init];
                                                        for(NSHTTPCookie *cookie in cookiesArray) {
                                                            [cookies setObject:[cookie valueForKey:@"value"] forKey:[cookie valueForKey:@"name"]];
                                                        }

                                                        NSLog(@"Cookies: %@", cookies);

                                                        if([cookies objectForKey:@"gym_gymnea"] != nil) {
                                                            // Update the session_id value and save in the GymneaWSClient singleton instance
                                                            [[GymneaWSClient sharedInstance] setSessionId:[cookies objectForKey:@"gym_gymnea"]];
                                                        }

                                                        completionBlock(success, results, cookies);

                                                    }];

    [sessionDataTask resume];
}

/*
- (void)performSyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth {
    
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPShouldHandleCookies:YES];

    if(auth != nil) {
        NSLog(@"uid: %@", auth.clientInfoHash);
        NSLog(@"ukey: %@", auth.clientKey);
        NSLog(@"session id: %@", [[GymneaWSClient sharedInstance] sessionId]);
        
        NSDictionary *SessionIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @".gymnea.com", NSHTTPCookieDomain,
                                                   @"/", NSHTTPCookiePath,
                                                   @"gym_gymnea", NSHTTPCookieName,
                                                   [[GymneaWSClient sharedInstance] sessionId], NSHTTPCookieValue,
                                                   nil];
        
        NSHTTPCookie *SessionIDPackagedCookie = [NSHTTPCookie cookieWithProperties:SessionIDCookieProperties];
        
        NSDictionary *UIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"uid", NSHTTPCookieName,
                                             auth.clientInfoHash, NSHTTPCookieValue,
                                             nil];
        
        NSHTTPCookie *UIDPackagedCookie = [NSHTTPCookie cookieWithProperties:UIDCookieProperties];
        
        NSDictionary *UKEYCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @".gymnea.com", NSHTTPCookieDomain,
                                              @"/", NSHTTPCookiePath,
                                              @"ukey", NSHTTPCookieName,
                                              auth.clientKey, NSHTTPCookieValue,
                                              nil];
        
        NSHTTPCookie *UKEYPackagedCookie = [NSHTTPCookie cookieWithProperties:UKEYCookieProperties];
        
        NSMutableArray *cookiesArray = [[NSMutableArray alloc] initWithObjects:UIDPackagedCookie, UKEYPackagedCookie, nil];
        if(SessionIDPackagedCookie != nil) {
            [cookiesArray addObject:SessionIDPackagedCookie];
        }
        
        NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
        [request setAllHTTPHeaderFields:cookies];
    }
    
    NSError *error;
    if(values != nil) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:0 error:&error];
        [request setHTTPBody:postData];
    }

    NSURLResponse * urlResponse = nil;

    NSData * responseData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&urlResponse
                                                              error:&error];

    NSLog(@"REQUEST: %@", [request allHTTPHeaderFields]);

    GymneaWSClientRequestStatus success = GymneaWSClientRequestError;
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)urlResponse;

    NSLog(@"HTTP RESPONSE: %@", response);

    NSInteger responseCode = response.statusCode;
    NSDictionary *results = nil;
    if(error == nil && ((responseCode/100)==2))
    {
        if(responseData != nil)
        {
            results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            NSLog(@"JSON RESULTS: %@", results);
            if(results != nil) {
                success = GymneaWSClientRequestSuccess;
            }
        }
    }

    NSArray *cookiesArray =[[NSArray alloc]init];
    cookiesArray = [NSHTTPCookie
                    cookiesWithResponseHeaderFields:[response allHeaderFields]
                    forURL:[NSURL URLWithString:@""]];
    
    NSMutableDictionary *cookies = [[NSMutableDictionary alloc] init];
    for(NSHTTPCookie *cookie in cookiesArray) {
        [cookies setObject:[cookie valueForKey:@"value"] forKey:[cookie valueForKey:@"name"]];
    }
    
    NSLog(@"Cookies: %@", cookies);
    
    if([cookies objectForKey:@"gym_gymnea"] != nil) {
        // Update the session_id value and save in the GymneaWSClient singleton instance
        [[GymneaWSClient sharedInstance] setSessionId:[cookies objectForKey:@"gym_gymnea"]];
    }

}

- (NSURLRequest *)connection: (NSURLConnection *)connection
             willSendRequest: (NSURLRequest *)request
            redirectResponse: (NSURLResponse *)redirectResponse;
{
    if (redirectResponse) {
        // The request you initialized the connection with should be kept as
        // _originalRequest.
        // Instead of trying to merge the pieces of _originalRequest into Cocoa
        // touch's proposed redirect request, we make a mutable copy of the
        // original request, change the URL to match that of the proposed
        // request, and return it as the request to use.
        //
        NSMutableURLRequest *r = [_originalRequest mutableCopy];
        [r setURL: [request URL]];
        return r;
    } else {
        return request;
    }
}
*/

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"athlete.gymnea.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
