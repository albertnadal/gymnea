//
//  WorkoutDetail+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 8/22/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDetail.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

@interface WorkoutDetail (Management)

+ (WorkoutDetail *)workoutWithWorkoutId:(int32_t)workoutId
                        withDescription:(NSString *)theDescription
                            withMuscles:(NSString *)muscles;

- (void)updateWithWorkoutId:(int32_t)workoutId
            withDescription:(NSString *)theDescription
                withMuscles:(NSString *)theMuscles;

/*
- (void)updateWithPhotoMaleSmallSecond:(NSData *)photoSmall;

- (void)updateWithPhotoMaleMediumSecond:(NSData *)photoMedium;

- (void)updateWithPhotoFemaleSmall:(NSData *)photoSmall withOrder:(GymneaExerciseImageOrder)order;

- (void)updateWithPhotoFemaleMedium:(NSData *)photoMedium withOrder:(GymneaExerciseImageOrder)order;

- (void)updateWithVideoLoop:(NSData *)video;
*/
+ (WorkoutDetail*)updateWorkoutWithId:(int)workoutId
                       withDictionary:(NSDictionary*)workoutDict;

- (void)updateWithDictionary:(NSDictionary *)workoutDict;

+ (WorkoutDetail*)getWorkoutDetailInfo:(int)workoutId;

@end
