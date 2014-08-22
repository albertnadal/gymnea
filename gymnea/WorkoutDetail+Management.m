//
//  WorkoutDetail+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 8/22/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDetail+Management.h"
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
/*
- (void)updateWithVideoLoop:(NSData *)video
{
    self.videoLoop = video;
    
    commitDefaultMOC();
}

- (void)updateWithPhotoMaleSmallSecond:(NSData *)photoSmall
{
    self.photoMaleSmallSecond = photoSmall;

    commitDefaultMOC();
}

- (void)updateWithPhotoMaleMediumSecond:(NSData *)photoMedium
{
    self.photoMaleMediumSecond = photoMedium;

    commitDefaultMOC();
}

- (void)updateWithPhotoFemaleSmall:(NSData *)photoSmall withOrder:(GymneaExerciseImageOrder)order
{
    if(order == ExerciseImageFirst) {
        self.photoFemaleSmallFirst = photoSmall;
    } else if(order == ExerciseImageSecond) {
        self.photoFemaleSmallSecond = photoSmall;
    }

    commitDefaultMOC();
}

- (void)updateWithPhotoFemaleMedium:(NSData *)photoMedium withOrder:(GymneaExerciseImageOrder)order
{
    if(order == ExerciseImageFirst) {
        self.photoFemaleMediumFirst = photoMedium;
    } else if(order == ExerciseImageSecond) {
        self.photoFemaleMediumSecond = photoMedium;
    }

    commitDefaultMOC();
}
*/
- (void)updateWithWorkoutId:(int32_t)workoutId
            withDescription:(NSString *)theDescription
                withMuscles:(NSString *)theMuscles
{
    self.workoutId = workoutId;
    self.workoutDescription = theDescription;
    self.muscles = theMuscles;
}

@end
