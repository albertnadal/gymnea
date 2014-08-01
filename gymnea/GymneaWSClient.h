//
//  CatalogWebServiceClient.h
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignUpInForm.h"

typedef enum _GymneaWSClientRequestStatus
{
    GymneaWSClientRequestSuccess = 1,
    GymneaWSClientRequestError = 0
} GymneaWSClientRequestStatus;

typedef enum _GymneaSignInWSClientRequestResponse
{
    GymneaSignInWSClientRequestSuccess = 1,
    GymneaSignInWSClientRequestError = 0
} GymneaSignInWSClientRequestResponse;

typedef enum _GymneaSignUpWSClientRequestResponse
{
    GymneaSignUpWSClientRequestSuccess = 1,
    GymneaSignUpWSClientRequestError = 0
} GymneaSignUpWSClientRequestResponse;

typedef void(^signInCompletionBlock)(GymneaSignInWSClientRequestResponse success, NSDictionary *responseData);
typedef void(^signUpCompletionBlock)(GymneaSignUpWSClientRequestResponse success, NSDictionary *responseData);

@interface GymneaWSClient : NSObject<NSURLSessionDelegate>

+ (GymneaWSClient *)sharedInstance;

- (void)signInForUsername:(NSString *)username
              andPassword:(NSString *)password
      withCompletionBlock:(signInCompletionBlock)completionBlock;

- (void)signUpWithForm:(SignUpInForm *)signInForm
      withCompletionBlock:(signUpCompletionBlock)completionBlock;

@end
