//
//  WorkoutDayExercise+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDayExercise.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

@interface WorkoutDayExercise (Management)

+ (WorkoutDayExercise *)workoutDayExerciseWithExerciseId:(int32_t)exerciseId
                                                   order:(int32_t)theOrder
                                                    reps:(NSString *)theReps
                                                    sets:(int32_t)theSets
                                                    time:(int32_t)theTime
                                                  muscle:(NSString *)theMuscle
                                                    name:(NSString *)theName
                                            workoutDayId:(int32_t)theWorkoutDayId
                                              workoutDay:(WorkoutDay *)theWorkoutDay;

- (void)updateWithExerciseId:(int32_t)exerciseId
                       order:(int32_t)theOrder
                        reps:(NSString *)theReps
                        sets:(int32_t)theSets
                        time:(int32_t)theTime
                      muscle:(NSString *)theMuscle
                        name:(NSString *)theName
                workoutDayId:(int32_t)theWorkoutDayId
                  workoutDay:(WorkoutDay *)theWorkoutDay;

+ (void)deleteWorkoutDayExercisesWithWorkoutDayId:(int)workoutDayId;

@end
