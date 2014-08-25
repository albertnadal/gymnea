//
//  WorkoutDay+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDay.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

@interface WorkoutDay (Management)

+ (WorkoutDay *)workoutDayWithWorkoutDayId:(int32_t)workoutDayId
                                 dayNumber:(int32_t)theDayNumber
                                       day:(NSString *)theDay
                                     title:(NSString *)theTitle
                                   workout:(WorkoutDetail *)theWorkout;

- (void)updateWithWorkoutDayId:(int32_t)workoutDayId
                     dayNumber:(int32_t)theDayNumber
                           day:(NSString *)theDay
                         title:(NSString *)theTitle
                       workout:(WorkoutDetail *)theWorkout;

- (void)updateWithWorkoutDayExercisesDict:(NSDictionary*)workoutDayExercisesDict;

+ (void)deleteWorkoutDayWithId:(int)workoutDayId;

@end
