//
//  WorkoutDayExercise+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDayExercise+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"WorkoutDayExercise";

@implementation WorkoutDayExercise (Management)

#pragma mark Insert methods

+ (WorkoutDayExercise *)workoutDayExerciseWithExerciseId:(int32_t)exerciseId
                                                   order:(int32_t)theOrder
                                                    reps:(NSString *)theReps
                                                    sets:(int32_t)theSets
                                                    time:(int32_t)theTime
                                                  muscle:(NSString *)theMuscle
                                                    name:(NSString *)theName
                                            workoutDayId:(int32_t)theWorkoutDayId
                                              workoutDay:(WorkoutDay *)theWorkoutDay
{
    WorkoutDayExercise *newWorkoutDayExercise = (WorkoutDayExercise *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

    [newWorkoutDayExercise updateWithExerciseId:exerciseId
                                          order:theOrder
                                           reps:theReps
                                           sets:theSets
                                           time:theTime
                                         muscle:theMuscle
                                           name:theName
                                   workoutDayId:theWorkoutDayId
                                     workoutDay:theWorkoutDay];

    commitDefaultMOC();
    return newWorkoutDayExercise;
}

- (void)updateWithExerciseId:(int32_t)exerciseId
                       order:(int32_t)theOrder
                        reps:(NSString *)theReps
                        sets:(int32_t)theSets
                        time:(int32_t)theTime
                      muscle:(NSString *)theMuscle
                        name:(NSString *)theName
                workoutDayId:(int32_t)theWorkoutDayId
                  workoutDay:(WorkoutDay *)theWorkoutDay
{
    self.exerciseId = exerciseId;
    self.order = theOrder;
    self.reps = theReps;
    self.sets = theSets;
    self.time = theTime;
    self.muscle = theMuscle;
    self.name = theName;
}

#pragma mark Delete methods

+ (void)deleteWorkoutDayExercisesWithWorkoutDayId:(int)workoutDayId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutDayId == %@", [NSNumber numberWithInt:workoutDayId]];

  deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());  
}

@end
