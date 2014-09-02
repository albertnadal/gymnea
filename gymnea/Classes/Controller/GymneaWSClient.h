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
#import "Workout+Management.h"
#import "WorkoutDetail+Management.h"
#import "WorkoutDayExercise+Management.h"
#import "UserInfo+Management.h"
#import "UserPicture+Management.h"

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
typedef void(^workoutDetailCompletionBlock)(GymneaWSClientRequestStatus success, WorkoutDetail *workout);
typedef void(^workoutPDFCompletionBlock)(GymneaWSClientRequestStatus success, NSData *pdf);
typedef void(^currentWorkoutCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^exerciseVideoLoopCompletionBlock)(GymneaWSClientRequestStatus success, NSData *video);
typedef void(^workoutsCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *workouts);
typedef void(^sessionIdCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^userPicturesCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *userPictures);

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

- (void)requestLocalUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock;

- (UserInfo *)requestLocalUserInfo;

- (void)requestUserImageWithCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestImageForExercise:(int)exerciseId
                       withSize:(GymneaExerciseImageSize)size
                     withGender:(GymneaExerciseImageGender)gender
                      withOrder:(GymneaExerciseImageOrder)order
            withCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestSavedExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestLocalExercisesWithType:(GymneaExerciseType)exerciseTypeId
                           withMuscle:(GymneaMuscleType)muscleId
                        withEquipment:(GymneaEquipmentType)equipmentId
                            withLevel:(GymneaExerciseLevel)levelId
                             withName:(NSString *)searchText
                  withCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestLocalExercisesWithType:(GymneaExerciseType)exerciseTypeId
                           withMuscle:(GymneaMuscleType)muscleId
                        withEquipment:(GymneaEquipmentType)equipmentId
                            withLevel:(GymneaExerciseLevel)levelId
                             withName:(NSString *)searchText
                      withExerciseIds:(NSArray *)exerciseIds
                  withCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestLocalSavedExercisesWithType:(GymneaExerciseType)exerciseTypeId
                                withMuscle:(GymneaMuscleType)muscleId
                             withEquipment:(GymneaEquipmentType)equipmentId
                                 withLevel:(GymneaExerciseLevel)levelId
                                  withName:(NSString *)searchText
                       withCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestExerciseDetailWithExercise:(Exercise *)exercise
                      withCompletionBlock:(exerciseDetailCompletionBlock)completionBlock;

- (void)requestExerciseVideoLoopWithExercise:(Exercise *)exercise
                         withCompletionBlock:(exerciseVideoLoopCompletionBlock)completionBlock;

- (void)requestWorkoutsWithCompletionBlock:(workoutsCompletionBlock)completionBlock;

- (void)requestSavedWorkoutsWithCompletionBlock:(workoutsCompletionBlock)completionBlock;

- (void)requestLocalWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                       withFrequency:(int)frequence
                           withLevel:(GymneaWorkoutLevel)levelId
                            withName:(NSString *)searchText
                 withCompletionBlock:(workoutsCompletionBlock)completionBlock;

- (void)requestLocalSavedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                            withFrequency:(int)frequence
                                withLevel:(GymneaWorkoutLevel)levelId
                                 withName:(NSString *)searchText
                      withCompletionBlock:(workoutsCompletionBlock)completionBlock;

- (void)requestLocalDownloadedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                                 withFrequency:(int)frequence
                                     withLevel:(GymneaWorkoutLevel)levelId
                                      withName:(NSString *)searchText
                           withCompletionBlock:(workoutsCompletionBlock)completionBlock;

- (void)requestImageForWorkout:(int)workoutId
                      withSize:(GymneaWorkoutImageSize)size
           withCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestWorkoutDetailWithWorkout:(Workout *)workout
                    withCompletionBlock:(workoutDetailCompletionBlock)completionBlock;

- (void)requestWorkoutPDFWithWorkout:(Workout *)workout
                 withCompletionBlock:(workoutPDFCompletionBlock)completionBlock;

- (void)setUserCurrentWorkoutWithWorkout:(Workout *)workout
                     withCompletionBlock:(currentWorkoutCompletionBlock)completionBlock;

- (void)requestUserPicturesWithCompletionBlock:(userPicturesCompletionBlock)completionBlock;

@end
