//
//  WorkoutDetail+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 8/22/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDetail+Management.h"
#import "WorkoutDay+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"WorkoutDetail";

@implementation WorkoutDetail (Management)

#pragma mark Insert methods

+ (WorkoutDetail *)workoutWithWorkoutId:(int32_t)workoutId
                        withDescription:(NSString *)theDescription
                            withMuscles:(NSString *)muscles
{
    WorkoutDetail *newWorkout = (WorkoutDetail *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

    [newWorkout updateWithWorkoutId:workoutId
                    withDescription:theDescription
                        withMuscles:muscles];

    commitDefaultMOC();
    return newWorkout;
}

- (void)updateWithDictionary:(NSDictionary *)workoutDict
{
    [self updateWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
              withDescription:[workoutDict objectForKey:@"description"]
                  withMuscles:[workoutDict objectForKey:@"muscles"]];

    commitDefaultMOC();
}

+ (WorkoutDetail*)updateWorkoutWithId:(int)workoutId
                       withDictionary:(NSDictionary*)workoutDict
{
    WorkoutDetail *workout = [WorkoutDetail getWorkoutDetailInfo:workoutId];

    if(workout != nil) {

        // Update register
        [workout updateWithDictionary:workoutDict];

    } else {

        // Insert register
        workout = [WorkoutDetail workoutWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
                                      withDescription:[workoutDict objectForKey:@"description"]
                                          withMuscles:[workoutDict objectForKey:@"muscles"]];
    }

    return workout;
}

+ (WorkoutDetail*)getWorkoutDetailInfo:(int)workoutId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutId == %d", workoutId];

  WorkoutDetail *workoutInfo = (WorkoutDetail*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return workoutInfo;
}

- (void)updateWithWorkoutId:(int32_t)workoutId
            withDescription:(NSString *)theDescription
                withMuscles:(NSString *)theMuscles
{
    self.workoutId = workoutId;
    self.workoutDescription = theDescription;
    self.muscles = theMuscles;
}

- (void)updateWithWorkoutDaysDict:(NSDictionary*)workoutDaysDict
{
    // If this workout already have workout days, so is necessary to update them.
/*    if(self.workoutDays != nil) {
        for(WorkoutDay* workoutDay in self.workoutDays) {
            [WorkoutDay deleteWorkoutDayWithId:workoutDay.workoutDayId];
        }
    }*/

    // Add all workout days
    NSMutableSet *workoutDaysList = [[NSMutableSet alloc] init];

    for (id workoutDayIdNumber in workoutDaysDict) {
        NSDictionary *workoutDayDict = [workoutDaysDict objectForKey:(NSNumber *)workoutDayIdNumber];

        // Create a workout day for this workout
        int workoutDayId = [workoutDayIdNumber intValue];
        WorkoutDay *workoutDay = [WorkoutDay workoutDayWithWorkoutDayId:workoutDayId
                                                              dayNumber:[[workoutDayDict objectForKey:@"dayNumber"] intValue]
                                                                    day:[workoutDayDict objectForKey:@"day"]
                                                                  title:[workoutDayDict objectForKey:@"title"]
                                                                workout:self];

        // Add the workout day exercises to the workout day
        [workoutDay updateWithWorkoutDayExercisesDict:[workoutDayDict objectForKey:@"exercises"]];

        // Add the workout day to the workout days list
        [workoutDaysList addObject:workoutDay];
    }

    self.workoutDays = [[NSSet alloc] initWithSet:workoutDaysList];

    commitDefaultMOC();
}

+ (void)deleteAll
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutId >= 0"];
    
    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

@end
