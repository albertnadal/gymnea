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
#import "EditPersonalProfileForm.h"
#import "EditUnitsMeasuresForm.h"
#import "EditEmailForm.h"
#import "EditAvatarForm.h"
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
typedef void(^editPersonalProfileCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString *message);
typedef void(^editUnitsMesuresProfileCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString *message);
typedef void(^editEmailCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString *message);
typedef void(^editAvatarCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSString *message);
typedef void(^userInfoCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, UserInfo *userInfo);
typedef void(^userImageCompletionBlock)(GymneaWSClientRequestStatus success, UIImage *userImage);
typedef void(^exerciseImageCompletionBlock)(GymneaWSClientRequestStatus success, UIImage *exerciseImage, int exerciseId);
typedef void(^workoutImageCompletionBlock)(GymneaWSClientRequestStatus success, UIImage *workoutImage, int workoutId);
typedef void(^exercisesCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *exercises);
typedef void(^exerciseDetailCompletionBlock)(GymneaWSClientRequestStatus success, ExerciseDetail *exercise);
typedef void(^workoutDetailCompletionBlock)(GymneaWSClientRequestStatus success, WorkoutDetail *workout);
typedef void(^workoutPDFCompletionBlock)(GymneaWSClientRequestStatus success, NSData *pdf);
typedef void(^currentWorkoutCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^exerciseVideoLoopCompletionBlock)(GymneaWSClientRequestStatus success, NSData *video);
typedef void(^workoutsCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *workouts);
typedef void(^workoutSaveWorkoutCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^workoutSaveExerciseCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^sessionIdCompletionBlock)(GymneaWSClientRequestStatus success);
typedef void(^userPicturesCompletionBlock)(GymneaWSClientRequestStatus success, NSArray *userPictures);
typedef void(^uploadUserPictureCompletionBlock)(GymneaWSClientRequestStatus success, NSNumber *userPictureId);
typedef void(^deleteUserPictureCompletionBlock)(GymneaWSClientRequestStatus success);

@interface GymneaWSClient : NSObject<NSURLConnectionDelegate, NSURLSessionDelegate>
{
    NSString *sessionId;
}

@property (nonatomic, retain) NSString *sessionId;

+ (GymneaWSClient *)sharedInstance;

- (void)signInForUsername:(NSString *)username
              andPassword:(NSString *)password
      withCompletionBlock:(signInCompletionBlock)completionBlock;

- (void)signUpWithForm:(SignUpForm *)signInForm
   withCompletionBlock:(signUpCompletionBlock)completionBlock;

- (void)editPersonalProfileWithForm:(EditPersonalProfileForm *)editProfileForm
                withCompletionBlock:(editPersonalProfileCompletionBlock)completionBlock;

- (void)editUnitsMeasuresProfileWithForm:(EditUnitsMeasuresForm *)editUnitsMeasuresForm
                     withCompletionBlock:(editUnitsMesuresProfileCompletionBlock)completionBlock;

- (void)editEmailProfileWithForm:(EditEmailForm *)editEmailForm
             withCompletionBlock:(editEmailCompletionBlock)completionBlock;

- (void)editAvatarWithForm:(EditAvatarForm *)editAvatarForm
       withCompletionBlock:(editAvatarCompletionBlock)completionBlock;

- (void)requestSessionIdWithCompletionBlock:(sessionIdCompletionBlock)completionBlock;

- (void)requestUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock;

- (void)requestLocalUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock;

- (UserInfo *)requestLocalUserInfo;

- (void)requestUserImageWithCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)requestImageForExercise:(int)exerciseId
                       withSize:(GymneaExerciseImageSize)size
                     withGender:(GymneaExerciseImageGender)gender
                      withOrder:(GymneaExerciseImageOrder)order
            withCompletionBlock:(exerciseImageCompletionBlock)completionBlock;

- (void)requestExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestSavedExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock;

- (void)requestSaveExercise:(Exercise *)exercise
        withCompletionBlock:(workoutSaveExerciseCompletionBlock)completionBlock;

- (void)requestUnsaveExercise:(Exercise *)exercise
          withCompletionBlock:(workoutSaveExerciseCompletionBlock)completionBlock;

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

- (void)requestSaveWorkout:(Workout *)workout
       withCompletionBlock:(workoutSaveWorkoutCompletionBlock)completionBlock;

- (void)requestUnsaveWorkout:(Workout *)workout
         withCompletionBlock:(workoutSaveWorkoutCompletionBlock)completionBlock;

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
           withCompletionBlock:(workoutImageCompletionBlock)completionBlock;

- (void)requestWorkoutDetailWithWorkout:(Workout *)workout
                    withCompletionBlock:(workoutDetailCompletionBlock)completionBlock;

- (void)requestWorkoutPDFWithWorkout:(Workout *)workout
                 withCompletionBlock:(workoutPDFCompletionBlock)completionBlock;

- (void)setUserCurrentWorkoutWithWorkout:(Workout *)workout
                     withCompletionBlock:(currentWorkoutCompletionBlock)completionBlock;

- (void)requestUserPicturesWithCompletionBlock:(userPicturesCompletionBlock)completionBlock;

- (void)requestImageForUserPicture:(int)pictureId
                          withSize:(GymneaUserPictureImageSize)size
               withCompletionBlock:(userImageCompletionBlock)completionBlock;

- (void)uploadUserPicture:(UserPicture *)userPicture
      withCompletionBlock:(uploadUserPictureCompletionBlock)completionBlock;

- (void)deleteUserPicture:(int)pictureId
      withCompletionBlock:(deleteUserPictureCompletionBlock)completionBlock;

@end
