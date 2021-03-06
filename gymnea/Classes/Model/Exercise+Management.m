//
//  Exercise+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "Exercise+Management.h"
#import "ExerciseDetail+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"Exercise";

@implementation Exercise (Management)

#pragma mark Insert methods

+ (Exercise *)exerciseWithExerciseId:(int32_t)exerciseId
                                name:(NSString *)name
                             isSaved:(BOOL)saved
                         equipmentId:(int32_t)equipmentId
                            muscleId:(int32_t)muscleId
                              typeId:(int32_t)typeId
                             levelId:(int32_t)levelId
                         photoMedium:(NSData*)photoMedium
                          photoSmall:(NSData*)photoSmall

{
    Exercise *newExercise = (Exercise *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];
    
    [newExercise updateWithExerciseId:exerciseId
                                 name:name
                              isSaved:saved
                          equipmentId:equipmentId
                             muscleId:muscleId
                               typeId:typeId
                              levelId:levelId
                          photoMedium:(NSData*)photoMedium
                           photoSmall:(NSData*)photoSmall];


    commitDefaultMOC();
    return newExercise;

}
/*
+ (UserInfo*)userInfoWithEmail:(NSString*)email
                     firstName:(NSString*)firstName
                      lastName:(NSString*)lastName
                        gender:(NSString*)gender
             heightCentimeters:(float)heightCentimeters
                heightIsMetric:(BOOL)heightIsMetric
               weightKilograms:(float)weightKilograms
                weightIsMetric:(BOOL)weightIsMetric
                       picture:(NSData*)picture
                     birthDate:(NSDate*)birthDate
{
  UserInfo *newUserInfo = (UserInfo *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

  [newUserInfo updateWithFirstName:firstName
                          lastName:lastName
                            gender:gender
                             email:email
                 heightCentimeters:heightCentimeters
                    heightIsMetric:heightIsMetric
                   weightKilograms:weightKilograms
                    weightIsMetric:weightIsMetric
                           picture:(NSData*)picture
                         birthDate:birthDate];

  commitDefaultMOC();
  return newUserInfo;
}
*/
- (void)updateWithDictionary:(NSDictionary *)exerciseDict
{

    [self updateWithExerciseId:[[exerciseDict objectForKey:@"id"] intValue]
                          name:[exerciseDict objectForKey:@"n"]
                       isSaved:[[exerciseDict objectForKey:@"s"] boolValue]
                   equipmentId:[[exerciseDict objectForKey:@"e"] intValue]
                      muscleId:[[exerciseDict objectForKey:@"m"] intValue]
                        typeId:[[exerciseDict objectForKey:@"t"] intValue]
                       levelId:[[exerciseDict objectForKey:@"l"] intValue]
                   photoMedium:[exerciseDict objectForKey:@"photoMedium"]
                    photoSmall:[exerciseDict objectForKey:@"photoSmall"]];

    commitDefaultMOC();
}

- (void)updateModelInDB
{
    commitDefaultMOC();
}

+ (Exercise*)updateExerciseWithId:(int)exerciseId withDictionary:(NSDictionary*)exerciseDict
{
    Exercise *exercise = [Exercise getExerciseInfo:exerciseId];

    if(exercise != nil) {

        // Update register
        [exercise updateWithDictionary:exerciseDict];

    } else {

        // Insert register
        exercise = [Exercise exerciseWithExerciseId:[[exerciseDict objectForKey:@"id"] intValue]
                                               name:[exerciseDict objectForKey:@"n"]
                                            isSaved:[[exerciseDict objectForKey:@"s"] boolValue]
                                        equipmentId:[[exerciseDict objectForKey:@"e"] intValue]
                                           muscleId:[[exerciseDict objectForKey:@"m"] intValue]
                                             typeId:[[exerciseDict objectForKey:@"t"] intValue]
                                            levelId:[[exerciseDict objectForKey:@"l"] intValue]
                                        photoMedium:[exerciseDict objectForKey:@"photoMedium"]
                                         photoSmall:[exerciseDict objectForKey:@"photoSmall"]];
    }

    return exercise;
}

+ (Exercise*)updateExerciseImageWithId:(int)exerciseId
                              withSize:(GymneaExerciseImageSize)size
                             withImage:(UIImage *)image
{
    Exercise *exercise = [Exercise getExerciseInfo:exerciseId];

    if(exercise != nil) {
        // Update register
        if(size == ExerciseImageSizeSmall) {
            [exercise setPhotoSmall:UIImagePNGRepresentation(image)];
        } else if(size == ExerciseImageSizeMedium) {
            [exercise setPhotoMedium:UIImagePNGRepresentation(image)];
        }

        commitDefaultMOC();
    }

    return exercise;
}

#pragma mark Select methods

+ (Exercise*)getExerciseInfo:(int)exerciseId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId == %d", exerciseId];

  Exercise *exerciseInfo = (Exercise*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return exerciseInfo;
}
/*
+ (NSArray*) getFeaturedEvents
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"featured == %d", YES];
  
  return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

#pragma mark Update methods

+ (void) resetFeaturedEvents
{
  NSArray *featuredEvents = [Event getFeaturedEvents];
  for (Event *event in featuredEvents)
    event.featured = NO;
  
  commitDefaultMOC();
}

- (void) updateWithEventDictionary:(NSDictionary *)eventDictionary
{
  NSDictionary *yelpInfo = [eventDictionary objectForKey:@"yelpInfo"];
  NSDictionary *eventVenue = [eventDictionary objectForKey:@"eventVenue"];
  
  [self updateWithDescription:[eventDictionary objectForKey:@"description"]
                        title:[eventDictionary objectForKey:@"title"]
                     featured:[[eventDictionary objectForKey:@"featured"] boolValue]
           imageHorizontalUrl:[eventDictionary objectForKey:@"imageHorizontalUrl"]
             imageVerticalUrl:[eventDictionary objectForKey:@"imageVerticalUrl"]
               imageSquareUrl:[eventDictionary objectForKey:@"imageSquareUrl"]
                  imageBigUrl:[eventDictionary objectForKey:@"imageBigUrl"]
               ageRestriction:[[eventDictionary objectForKey:@"ageRestriction"] unsignedIntegerValue]
                       rating:[[yelpInfo objectForKey:@"rating"] unsignedIntegerValue]
                      venueId:[[eventDictionary objectForKey:@"venueId"] unsignedIntegerValue]
                    venueName:[eventVenue objectForKey:@"name"]
                 venueCountry:[eventVenue objectForKey:@"country"]
                    venueCity:[eventVenue objectForKey:@"city"]
                  venueStreet:[eventVenue objectForKey:@"street"]
      venueCoordinateLatitude:[[eventVenue objectForKey:@"coordinateLatitude"] doubleValue]
     venueCoordinateLongitude:[[eventVenue objectForKey:@"coordinateLongitude"] doubleValue]
                   venueState:[eventVenue objectForKey:@"venueState"]
                  priceLowest:[[eventDictionary objectForKey:@"priceLowest"] floatValue]
                 priceHighest:[[eventDictionary objectForKey:@"priceLowest"] floatValue]];
  
  commitDefaultMOC();
}

- (void) updateWithExerciseDictionary:(NSDictionary *)exerciseDictionary
{

  self.featured = YES;
  self.title = [featuredEventDictionary objectForKey:@"title"];
  self.imageHorizontalUrl = [featuredEventDictionary objectForKey:@"imageHorizontalUrl"];
  self.imageVerticalUrl = [featuredEventDictionary objectForKey:@"imageVerticallUrl"];
  self.imageSquareUrl = [featuredEventDictionary objectForKey:@"imageSquareUrl"];
  self.imageBigUrl = [featuredEventDictionary objectForKey:@"imageBigUrl"];
  self.venueName = [eventVenue objectForKey:@"name"];
  self.priceLowest = [[featuredEventDictionary objectForKey:@"priceLowest"] floatValue];
  self.priceHighest = [[featuredEventDictionary objectForKey:@"priceHighest"] floatValue];

  commitDefaultMOC();
}
*/
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

- (void)updateWithExerciseId:(int32_t)exerciseId
                        name:(NSString *)name
                     isSaved:(BOOL)saved
                 equipmentId:(int32_t)equipmentId
                    muscleId:(int32_t)muscleId
                      typeId:(int32_t)typeId
                     levelId:(int32_t)levelId
                 photoMedium:(NSData*)photoMedium
                  photoSmall:(NSData*)photoSmall

{
  self.exerciseId = exerciseId;
  self.name = name;
  self.saved = saved;
  self.equipmentId = equipmentId;
  self.muscleId = muscleId;
  self.typeId = typeId;
  self.levelId = levelId;
  self.photoMedium = photoMedium;
  self.photoSmall = photoSmall;
}

+ (NSArray *)getExercises
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId > %d", 0];

    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

+ (NSArray *)getSavedExercises
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saved == YES"];
    
    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

+ (NSArray *)getDownloadedExercises
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoLoop != nil"];
    
    NSArray *downloadedExerciseDetail = fetchManagedObjects(@"ExerciseDetail", predicate, nil, defaultManagedObjectContext());
    NSMutableArray *downloadedExercises = [[NSMutableArray alloc] init];
    for(ExerciseDetail *exerciseDetail in downloadedExerciseDetail) {
        [downloadedExercises addObject:[Exercise getExerciseInfo:exerciseDetail.exerciseId]];
    }

    return [NSArray arrayWithArray:downloadedExercises];
}

+ (NSArray *)getExercisesWithType:(GymneaExerciseType)exerciseTypeId
                       withMuscle:(GymneaMuscleType)muscleId
                    withEquipment:(GymneaEquipmentType)equipmentId
                        withLevel:(GymneaExerciseLevel)levelId
                         withName:(NSString *)searchText
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];

    NSString *queryString = nil;

    if(exerciseTypeId != GymneaExerciseAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:exerciseTypeId]];
        [queryStringArray addObject:queryString];
    }

    if(muscleId != GymneaMuscleAny) {
        queryString = [NSString stringWithFormat:@"(muscleId == %@)", [NSNumber numberWithInt:muscleId]];
        [queryStringArray addObject:queryString];
    }

    if(equipmentId != GymneaEquipmentAny) {
        queryString = [NSString stringWithFormat:@"(equipmentId == %@)", [NSNumber numberWithInt:equipmentId]];
        [queryStringArray addObject:queryString];
    }

    if(levelId != GymneaExerciseLevelAny) {
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
        return [Exercise getExercises];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

+ (NSArray *)getExercisesWithType:(GymneaExerciseType)exerciseTypeId
                       withMuscle:(GymneaMuscleType)muscleId
                    withEquipment:(GymneaEquipmentType)equipmentId
                        withLevel:(GymneaExerciseLevel)levelId
                         withName:(NSString *)searchText
                  withExerciseIds:(NSArray *)exerciseIds
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];
    
    NSString *queryString = nil;
    
    if(exerciseTypeId != GymneaExerciseAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:exerciseTypeId]];
        [queryStringArray addObject:queryString];
    }
    
    if(muscleId != GymneaMuscleAny) {
        queryString = [NSString stringWithFormat:@"(muscleId == %@)", [NSNumber numberWithInt:muscleId]];
        [queryStringArray addObject:queryString];
    }
    
    if(equipmentId != GymneaEquipmentAny) {
        queryString = [NSString stringWithFormat:@"(equipmentId == %@)", [NSNumber numberWithInt:equipmentId]];
        [queryStringArray addObject:queryString];
    }
    
    if(levelId != GymneaExerciseLevelAny) {
        queryString = [NSString stringWithFormat:@"(levelId == %@)", [NSNumber numberWithInt:levelId]];
        [queryStringArray addObject:queryString];
    }

    if(exerciseIds != nil) {

        NSString *exerciseIdsString = @"";
        BOOL isFirstExerciseId = TRUE;
        for(NSNumber *exerciseIdNumber in exerciseIds) {

            if(isFirstExerciseId) {
                exerciseIdsString = [exerciseIdsString stringByAppendingString:[NSString stringWithFormat:@"(exerciseId == %@)", exerciseIdNumber]];
                isFirstExerciseId = FALSE;
            } else {
                exerciseIdsString = [exerciseIdsString stringByAppendingString:[NSString stringWithFormat:@" OR (exerciseId == %@)", exerciseIdNumber]];
            }
        }

        queryString = [NSString stringWithFormat:@"(%@)", exerciseIdsString];
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
        return [Exercise getExercises];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

+ (NSArray *)getSavedExercisesWithType:(GymneaExerciseType)exerciseTypeId
                            withMuscle:(GymneaMuscleType)muscleId
                         withEquipment:(GymneaEquipmentType)equipmentId
                             withLevel:(GymneaExerciseLevel)levelId
                              withName:(NSString *)searchText
{
    NSMutableArray *queryStringArray = [[NSMutableArray alloc] init];
    
    NSString *queryString = nil;
    
    if(exerciseTypeId != GymneaExerciseAny) {
        queryString = [NSString stringWithFormat:@"(typeId == %@)", [NSNumber numberWithInt:exerciseTypeId]];
        [queryStringArray addObject:queryString];
    }
    
    if(muscleId != GymneaMuscleAny) {
        queryString = [NSString stringWithFormat:@"(muscleId == %@)", [NSNumber numberWithInt:muscleId]];
        [queryStringArray addObject:queryString];
    }
    
    if(equipmentId != GymneaEquipmentAny) {
        queryString = [NSString stringWithFormat:@"(equipmentId == %@)", [NSNumber numberWithInt:equipmentId]];
        [queryStringArray addObject:queryString];
    }
    
    if(levelId != GymneaExerciseLevelAny) {
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
        return [Exercise getSavedExercises];
    } else {
        queryString = [NSString stringWithFormat:@"%@ AND (saved == YES)", queryString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
        return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
    }
}

+ (void)deleteAll
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId >= 0"];
    
    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

@end
