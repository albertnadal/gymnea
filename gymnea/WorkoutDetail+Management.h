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

- (void)updateWithWorkoutDaysDict:(NSDictionary*)workoutDaysDict;

+ (WorkoutDetail*)updateWorkoutWithId:(int)workoutId
                       withDictionary:(NSDictionary*)workoutDict;

- (void)updateWithDictionary:(NSDictionary *)workoutDict;

+ (WorkoutDetail*)getWorkoutDetailInfo:(int)workoutId;

@end
