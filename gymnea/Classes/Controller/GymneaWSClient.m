//
//  CatalogWebServiceClient.m
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GymneaWSClient.h"
#import "GEAAuthentication.h"
#import "GEAAuthenticationKeychainStore.h"

static const NSString *kWSDomain = @"athlete.gymnea.com";

@interface GymneaWSClient ()

typedef void(^responseCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *responseCookies);

- (void) performAsyncRequest:(NSString *)path
              withDictionary:(NSDictionary *)values
          withAuthentication:(GEAAuthentication *)auth
         withCompletionBlock:(responseCompletionBlock)completionBlock;

@end

@implementation GymneaWSClient

@synthesize sessionId;

+ (GymneaWSClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    static GymneaWSClient *_instance;

    dispatch_once(&onceToken, ^{
        _instance = [[GymneaWSClient alloc] init];
    });

    return _instance;
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
                                                                                          clientInfoHash:[cookies objectForKey:@"uid"]
                                                                                               clientKey:[cookies objectForKey:@"ukey"]];

                      GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
                      [keychainStore setAuthentication:authentication forIdentifier:@"gymnea"];
                  }

                  NSDictionary *userInfoDict = [responseData objectForKey:@"userInfo"];

                  userInfo = [[UserInfo alloc] init];
                  [userInfo setFirstName:[userInfoDict objectForKey:@"firstname"]];
                  [userInfo setLastName:[userInfoDict objectForKey:@"lastname"]];
                  [userInfo setGender:[userInfoDict objectForKey:@"gender"]];
                  [userInfo setEmail:[userInfoDict objectForKey:@"email"]];
                  [userInfo setHeightCentimeters:[[userInfoDict objectForKey:@"centimeters"] floatValue]];
                  [userInfo setHeightIsMetric:[[userInfoDict objectForKey:@"heightIsMetric"] boolValue]];
                  [userInfo setWeightKilograms:[[userInfoDict objectForKey:@"kilograms"] floatValue]];
                  [userInfo setWeightIsMetric:[[userInfoDict objectForKey:@"weightIsMetric"] boolValue]];

                  NSCalendar *calendar = [NSCalendar currentCalendar];
                  NSDateComponents *components = [[NSDateComponents alloc] init];
                  [components setDay:[[userInfoDict objectForKey:@"day"] intValue]];
                  [components setMonth:[[userInfoDict objectForKey:@"month"] intValue]];
                  [components setYear:[[userInfoDict objectForKey:@"year"] intValue]];
                  [userInfo setBirthDate:[calendar dateFromComponents:components]];

                  // Now we make a fake request to update the session id
                  [self requestSessionId];
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
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signUpStatus, responseData, userInfo);
              });

          }];

}

- (void)requestSessionId
{
    [self requestUserInfoWithCompletionBlock:nil];
}

- (void)requestUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock
{
    NSString *requestPath = @"/api/user/get_user_info";

    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    [self performAsyncRequest:requestPath
               withDictionary:nil
           withAuthentication:auth
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              UserInfo *userInfo = nil;

              if(success == GymneaWSClientRequestSuccess) {

                  userInfo = [[UserInfo alloc] init];
                  NSDictionary *userInfoDict = [responseData objectForKey:@"userInfo"];

                  userInfo = [[UserInfo alloc] init];
                  [userInfo setFirstName:[userInfoDict objectForKey:@"firstname"]];
                  [userInfo setLastName:[userInfoDict objectForKey:@"lastname"]];
                  [userInfo setGender:[userInfoDict objectForKey:@"gender"]];
                  [userInfo setEmail:[userInfoDict objectForKey:@"email"]];
                  [userInfo setHeightCentimeters:[[userInfoDict objectForKey:@"centimeters"] floatValue]];
                  [userInfo setHeightIsMetric:[[userInfoDict objectForKey:@"heightIsMetric"] boolValue]];
                  [userInfo setWeightKilograms:[[userInfoDict objectForKey:@"kilograms"] floatValue]];
                  [userInfo setWeightIsMetric:[[userInfoDict objectForKey:@"weightIsMetric"] boolValue]];

                  NSCalendar *calendar = [NSCalendar currentCalendar];
                  NSDateComponents *components = [[NSDateComponents alloc] init];
                  [components setDay:[[userInfoDict objectForKey:@"day"] intValue]];
                  [components setMonth:[[userInfoDict objectForKey:@"month"] intValue]];
                  [components setYear:[[userInfoDict objectForKey:@"year"] intValue]];
                  [userInfo setBirthDate:[calendar dateFromComponents:components]];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  if(completionBlock != nil) {
                      completionBlock(success, responseData, userInfo);
                  }
              });

          }];
}

/*
- (void)retrieveBook:(int)identifier
 withCompletionBlock:(bookDetailsCompletionBlock)completionBlock
{
    NSString *requestPath = [NSString stringWithFormat:@"/api/v10/items/%d", identifier];

    [self performAsyncRequest:requestPath
          withCompletionBlock:^(CatalogWSClientRequestError success, NSDictionary *responseData)
     {
         // BookDetails object mapping with the received JSON data
         int bookId = [[responseData objectForKey:@"id"] intValue];
         NSString *bookImage = (NSString *)[responseData objectForKey:@"image"];
         NSString *bookTitle = (NSString *)[responseData objectForKey:@"title"];
         NSString *bookAuthor = (NSString *)[responseData objectForKey:@"author"];
         double bookPrice = [[responseData objectForKey:@"price"] doubleValue];

         BookDetails *book = [[BookDetails alloc] initWithId:bookId image:bookImage title:bookTitle author:bookAuthor price:bookPrice];

         dispatch_async(dispatch_get_main_queue(), ^{
             completionBlock(success, book);
         });

     }];
}
*/
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
