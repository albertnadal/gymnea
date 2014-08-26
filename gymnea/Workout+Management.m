//
//  Workout+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "Workout+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"Workout";

@implementation Workout (Management)

#pragma mark Insert methods

+ (Workout *)workoutWithWorkoutId:(int32_t)workoutId
                             name:(NSString *)name
                          isSaved:(BOOL)saved
                        frequency:(int32_t)frequency
                           typeId:(int32_t)typeId
                          levelId:(int32_t)levelId
                      photoMedium:(NSData*)photoMedium
                       photoSmall:(NSData*)photoSmall

{
    Workout *newWorkout = (Workout *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];
    
    [newWorkout updateWithWorkoutId:workoutId
                               name:name
                            isSaved:saved
                          frequency:frequency
                             typeId:typeId
                            levelId:levelId
                        photoMedium:(NSData*)photoMedium
                         photoSmall:(NSData*)photoSmall];

    commitDefaultMOC();
    return newWorkout;
}

- (void)updateWithDictionary:(NSDictionary *)workoutDict
{

    [self updateWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
                         name:[workoutDict objectForKey:@"n"]
                      isSaved:[[workoutDict objectForKey:@"s"] boolValue]
                    frequency:[[workoutDict objectForKey:@"f"] intValue]
                       typeId:[[workoutDict objectForKey:@"t"] intValue]
                      levelId:[[workoutDict objectForKey:@"l"] intValue]
                  photoMedium:[workoutDict objectForKey:@"photoMedium"]
                   photoSmall:[workoutDict objectForKey:@"photoSmall"]];

    commitDefaultMOC();
}

- (void)updateModelInDB
{
    commitDefaultMOC();
}

+ (Workout*)updateWorkoutWithId:(int)workoutId withDictionary:(NSDictionary*)workoutDict
{
    Workout *workout = [Workout getWorkoutInfo:workoutId];

    if(workout != nil) {

        // Update register
        [workout updateWithDictionary:workoutDict];

    } else {

        // Insert register
        workout = [Workout workoutWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
                                           name:[workoutDict objectForKey:@"n"]
                                        isSaved:[[workoutDict objectForKey:@"s"] boolValue]
                                      frequency:[[workoutDict objectForKey:@"f"] intValue]
                                         typeId:[[workoutDict objectForKey:@"t"] intValue]
                                        levelId:[[workoutDict objectForKey:@"l"] intValue]
                                    photoMedium:[workoutDict objectForKey:@"photoMedium"]
                                     photoSmall:[workoutDict objectForKey:@"photoSmall"]];
    }

    return workout;
}

+ (Workout*)updateWorkoutImageWithId:(int)workoutId
                            withSize:(GymneaWorkoutImageSize)size
                           withImage:(UIImage *)image
{
    Workout *workout = [Workout getWorkoutInfo:workoutId];

    if(workout != nil) {
        // Update register
        if(size == WorkoutImageSizeSmall) {
            [workout setPhotoSmall:UIImagePNGRepresentation(image)];
        } else if(size == WorkoutImageSizeMedium) {
            [workout setPhotoMedium:UIImagePNGRepresentation(image)];
        }

        commitDefaultMOC();
    }

    return workout;
}

#pragma mark Select methods

+ (Workout*)getWorkoutInfo:(int)workoutId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutId == %d", workoutId];

  Workout *workoutInfo = (Workout*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return workoutInfo;
}

- (void)updateWithPhotoMedium:(NSData *)photoMedium
{
    self.photoMedium = photoMedium;

    commitDefaultMOC();
}

- (void)updateWithPhotoSmall:(NSData *)photoSmall
{
    self.photoSmall = photoSmall;

    commitDefaultMOC();
}

- (void)updateWithWorkoutId:(int32_t)workoutId
                       name:(NSString *)name
                    isSaved:(BOOL)saved
                  frequency:(int32_t)frequency
                     typeId:(int32_t)typeId
                    levelId:(int32_t)levelId
                photoMedium:(NSData*)photoMedium
                 photoSmall:(NSData*)photoSmall

{
  self.workoutId = workoutId;
  self.name = name;
  self.saved = saved;
  self.frequency = frequency;
  self.typeId = typeId;
  self.levelId = levelId;
  self.photoMedium = photoMedium;
  self.photoSmall = photoSmall;
}

+ (NSArray *)getWorkouts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"workoutId > %d", 0];

    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

+ (NSArray *)getSavedWorkouts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved == YES"];
    
    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

+ (NSArray *)getDownloadedWorkouts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"downloaded == YES"];
    
    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

+ (NSArray *)getWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                   withFrequency:(int)frequency
                       withLevel:(GymneaWorkoutLevel)levelId
                        withName:(NSString *)searchText
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];

    NSString *queryString = nil;

    if(workoutTypeId != GymneaWorkoutAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:workoutTypeId]];
        [queryStringArray addObject:queryString];
    }

    if(frequency > 0) {
        queryString = [NSString stringWithFormat:@"(frequency == %@)", [NSNumber numberWithInt:frequency]];
        [queryStringArray addObject:queryString];
    }

    if(levelId != GymneaWorkoutLevelAny) {
        queryString = [NSString stringWithFormat:@"(levelId == %@)", [NSNumber numberWithInt:levelId]];
        [queryStringArray addObject:queryString];
    }

    if(![searchText isEqualToString:@""]) {
        queryString = [NSString stringWithFormat:@"(name MATCHES[cd] '.*(%@).*')", searchText];
        [queryStringArray addObject:queryString];
    }

    queryString = @"";
    NSString *queryPredicateString = nil;

    BOOL isFirstPredicate = TRUE;
    for(queryPredicateString in queryStringArray)
    {
        if(isFirstPredicate) {
            queryString = [queryString stringByAppendingString:queryPredicateString];
            isFirstPredicate = FALSE;
        } else {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" AND %@", queryPredicateString]];
        }
    }

    if([queryString isEqualToString:@""]) {
        return [Workout getWorkouts];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

+ (NSArray *)getDownloadedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                             withFrequency:(int)frequency
                                 withLevel:(GymneaWorkoutLevel)levelId
                                  withName:(NSString *)searchText
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];
    
    NSString *queryString = @"(downloaded == YES)";
    [queryStringArray addObject:queryString];

    if(workoutTypeId != GymneaWorkoutAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:workoutTypeId]];
        [queryStringArray addObject:queryString];
    }
    
    if(frequency > 0) {
        queryString = [NSString stringWithFormat:@"(frequency == %@)", [NSNumber numberWithInt:frequency]];
        [queryStringArray addObject:queryString];
    }
    
    if(levelId != GymneaWorkoutLevelAny) {
        queryString = [NSString stringWithFormat:@"(levelId == %@)", [NSNumber numberWithInt:levelId]];
        [queryStringArray addObject:queryString];
    }
    
    if(![searchText isEqualToString:@""]) {
        queryString = [NSString stringWithFormat:@"(name MATCHES[cd] '.*(%@).*')", searchText];
        [queryStringArray addObject:queryString];
    }
    
    queryString = @"";
    NSString *queryPredicateString = nil;
    
    BOOL isFirstPredicate = TRUE;
    for(queryPredicateString in queryStringArray)
    {
        if(isFirstPredicate) {
            queryString = [queryString stringByAppendingString:queryPredicateString];
            isFirstPredicate = FALSE;
        } else {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" AND %@", queryPredicateString]];
        }
    }
    
    if([queryString isEqualToString:@""]) {
        return [Workout getDownloadedWorkouts];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

+ (NSArray *)getSavedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                        withFrequency:(int)frequency
                            withLevel:(GymneaWorkoutLevel)levelId
                             withName:(NSString *)searchText
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];
    
    NSString *queryString = nil;
    
    if(workoutTypeId != GymneaWorkoutAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:workoutTypeId]];
        [queryStringArray addObject:queryString];
    }
    
    if(frequency > 0) {
        queryString = [NSString stringWithFormat:@"(frequency == %@)", [NSNumber numberWithInt:frequency]];
        [queryStringArray addObject:queryString];
    }
    
    if(levelId != GymneaWorkoutLevelAny) {
        queryString = [NSString stringWithFormat:@"(levelId == %@)", [NSNumber numberWithInt:levelId]];
        [queryStringArray addObject:queryString];
    }
    
    if(![searchText isEqualToString:@""]) {
        queryString = [NSString stringWithFormat:@"(name MATCHES[cd] '.*(%@).*')", searchText];
        [queryStringArray addObject:queryString];
    }
    
    queryString = @"";
    NSString *queryPredicateString = nil;
    
    BOOL isFirstPredicate = TRUE;
    for(queryPredicateString in queryStringArray)
    {
        if(isFirstPredicate) {
            queryString = [queryString stringByAppendingString:queryPredicateString];
            isFirstPredicate = FALSE;
        } else {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@" AND %@", queryPredicateString]];
        }
    }
    
    if([queryString isEqualToString:@""]) {
        return [Workout getSavedWorkouts];
    } else {
        queryString = [NSString stringWithFormat:@"%@ AND (saved == YES)", queryString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

@end
