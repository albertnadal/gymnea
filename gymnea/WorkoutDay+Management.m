//
//  WorkoutDay+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDay+Management.h"
#import "WorkoutDayExercise+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"WorkoutDay";

@implementation WorkoutDay (Management)

#pragma mark Insert methods

+ (WorkoutDay *)workoutDayWithWorkoutDayId:(int32_t)workoutDayId
                                 dayNumber:(int32_t)theDayNumber
                                       day:(NSString *)theDay
                                     title:(NSString *)theTitle
                                   workout:(WorkoutDetail *)theWorkout
{
    WorkoutDay *newWorkoutDay = (WorkoutDay *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

    [newWorkoutDay updateWithWorkoutDayId:workoutDayId
                                dayNumber:theDayNumber
                                      day:theDay
                                    title:theTitle
                                  workout:theWorkout];

    commitDefaultMOC();
    return newWorkoutDay;
}

- (void)updateWithWorkoutDayId:(int32_t)workoutDayId
                     dayNumber:(int32_t)theDayNumber
                           day:(NSString *)theDay
                         title:(NSString *)theTitle
                       workout:(WorkoutDetail *)theWorkout
{
    self.workoutDayId = workoutDayId;
    self.dayNumber = theDayNumber;
    self.dayName = theDay;
    self.title = theTitle;
    self.workout = theWorkout;
}

- (void)updateWithWorkoutDayExercisesDict:(NSDictionary*)workoutDayExercisesDict
{
    // This workout day already have workout day exercises, so is necessary to update them.
    [WorkoutDayExercise deleteWorkoutDayExercisesWithWorkoutDayId:self.workoutDayId];

    // Add all workout days
    NSMutableSet *workoutDayExercisesList = [[NSMutableSet alloc] init];

    for (NSDictionary *workoutDayExerciseDict in workoutDayExercisesDict) {

        WorkoutDayExercise *workoutDayExercise = [WorkoutDayExercise workoutDayExerciseWithExerciseId:[[workoutDayExerciseDict objectForKey:@"id_exercise"] intValue]
                                                                                                order:[[workoutDayExerciseDict objectForKey:@"order"] intValue]
                                                                                                 reps:[workoutDayExerciseDict objectForKey:@"reps"]
                                                                                                 sets:[[workoutDayExerciseDict objectForKey:@"sets"] intValue]
                                                                                                 time:[[workoutDayExerciseDict objectForKey:@"time"] intValue]
                                                                                               muscle:[workoutDayExerciseDict objectForKey:@"muscle"]
                                                                                                 name:[workoutDayExerciseDict objectForKey:@"exercise"]
                                                                                         workoutDayId:self.workoutDayId
                                                                                           workoutDay:self];

        [workoutDayExercisesList addObject:workoutDayExercise];
    }

    self.workoutDayExercises = [[NSSet alloc] initWithSet:workoutDayExercisesList];

    commitDefaultMOC();
}

#pragma mark Delete methods

+ (void)deleteWorkoutDayWithId:(int)workoutDayId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutDayId == %@", [NSNumber numberWithInt:workoutDayId]];
  
  deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());  
}

@end
