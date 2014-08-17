//
//  GymneaWSClient.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/08/14.
//  Copyright (c) 2014 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GEADefinitions.h"
#import "SignUpForm.h"
#import "Exercise+Management.h"
#import "ExerciseDetail+Management.h"
#import "UserInfo+Management.h"

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

typedef void(^signInCompletionBlock)(GymneaSignInWSClientRequestResponse success, NSDictionary *responseData, UserInfo *userInfo);
typedef void(^signUpCompletionBlock)(GymneaSignUpWSClientRequestResponse success, NSDictionary *responseData, UserInfo *userInfo);
typedef void(^userInfoCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, UserInfo *userInfo);
typedef void(^userImageCompletionBlock)(GymneaWSClientRequestStatus success, UIImage *userImage);
typedef void(^exercisesCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *exercises);
typedef void(^exerciseDetailCompletionBlock)(GymneaWSClientRequestStatus success, ExerciseDetail *exercise);
typedef void(^sessionIdCompletionBlock)(GymneaWSClientRequestStatus success);

@interface GymneaWSClient : NSObject<NSURLConnectionDelegate, NSURLSessionDelegate>
{
    NSString *sessionId;
}

+ (GymneaWSClient *)sharedInstance;

- (void)signInForUsername:(NSString *)username
              andPassword:(NSString *)password
      withCompletionBlock:(signInCompletionBlock)completionBlock;

- (void)signUpWithForm:(SignUpForm *)signInForm
   withCompletionBlock:(signUpCompletionBlock)completionBlock;

- (void)requestSessionIdWithCompletionBlock:(sessionIdCompletionBlock)completionBlock;

- (void)requestUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock;

- (void)requestUserImageWithCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestImageForExercise:(int)exerciseId
                       withSize:(GymneaExerciseImageSize)size
                     withGender:(GymneaExerciseImageGender)gender
                      withOrder:(GymneaExerciseImageOrder)order
            withCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestLocalExercisesWithType:(GymneaExerciseType)exerciseTypeId
                           withMuscle:(GymneaMuscleType)muscleId
                        withEquipment:(GymneaEquipmentType)equipmentId
                            withLevel:(GymneaExerciseLevel)levelId
                             withName:(NSString *)searchText
                  withCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestExerciseDetailWithExercise:(Exercise *)exercise
                      withCompletionBlock:(exerciseDetailCompletionBlock)completionBlock;

@end
