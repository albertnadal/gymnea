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
         withCompletionBlock:(responseCompletionBlock)completionBlock;

@end

@implementation GymneaWSClient

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
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

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

              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signInStatus, responseData);
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
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              GymneaSignUpWSClientRequestResponse signUpStatus = GymneaSignUpWSClientRequestError;

              if(success == GymneaWSClientRequestSuccess) {
                  signUpStatus = GymneaSignUpWSClientRequestSuccess;
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signUpStatus, responseData);
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
        withCompletionBlock:(responseCompletionBlock)completionBlock {

    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPShouldHandleCookies:YES];

    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:0 error:&error];
    [request setHTTPBody:postData];


    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];

    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *responseData, NSURLResponse *urlResponse, NSError *error) {

                                                        GymneaWSClientRequestStatus success = GymneaWSClientRequestError;
                                                        NSHTTPURLResponse *response = (NSHTTPURLResponse*)urlResponse;

                                                        //NSLog(@"HTTP RESPONSE: %@", response);

                                                        NSInteger responseCode = response.statusCode;
                                                        NSDictionary *results = nil;
                                                        if(error == nil && ((responseCode/100)==2))
                                                        {
                                                            if(responseData != nil)
                                                            {
                                                                results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                                                                //NSLog(@"JSON RESULTS: %@", results);
                                                                success = GymneaWSClientRequestSuccess;
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

                                                        //NSLog(@"Cookies: %@", cookies);

                                                        completionBlock(success, results, cookies);
                                                    }];

    [sessionDataTask resume];
}

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
