//
//  Workout+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "Workout.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

typedef enum _GymneaWorkoutImageSize
{
    WorkoutImageSizeSmall = 0,
    WorkoutImageSizeMedium = 1
} GymneaWorkoutImageSize;

@interface Workout (Management)

+ (Workout *)workoutWithWorkoutId:(int32_t)workoutId
                             name:(NSString *)name
                          isSaved:(BOOL)saved
                        frequency:(int32_t)frequency
                           typeId:(int32_t)typeId
                          levelId:(int32_t)levelId
                      photoMedium:(NSData*)photoMedium
                       photoSmall:(NSData*)photoSmall;

- (void)updateWithWorkoutId:(int32_t)workoutId
                       name:(NSString *)name
                    isSaved:(BOOL)saved
                  frequency:(int32_t)frequency
                     typeId:(int32_t)typeId
                    levelId:(int32_t)levelId
                photoMedium:(NSData*)photoMedium
                 photoSmall:(NSData*)photoSmall;

- (void)updateWithPhotoMedium:(NSData *)photoMedium;

- (void)updateWithPhotoSmall:(NSData *)photoSmall;

- (void)updateModelInDB;

- (void)updateWithDictionary:(NSDictionary *)workoutDict;

+ (Workout*)updateWorkoutWithId:(int)workoutId withDictionary:(NSDictionary*)workoutDict;

+ (Workout*)updateWorkoutImageWithId:(int)workoutId
                            withSize:(GymneaWorkoutImageSize)size
                           withImage:(UIImage *)image;

+ (Workout*)getWorkoutInfo:(int)workoutId;

+ (NSArray *)getWorkouts;

+ (NSArray *)getSavedWorkouts;

+ (NSArray *)getDownloadedWorkouts;

+ (NSArray *)getWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                   withFrequency:(int)frequency
                       withLevel:(GymneaWorkoutLevel)levelId
                        withName:(NSString *)searchText;

+ (NSArray *)getDownloadedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                             withFrequency:(int)frequency
                                 withLevel:(GymneaWorkoutLevel)levelId
                                  withName:(NSString *)searchText;

+ (NSArray *)getSavedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                        withFrequency:(int)frequency
                            withLevel:(GymneaWorkoutLevel)levelId
                             withName:(NSString *)searchText;

@end
