//
//  Exercise+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExerciseDetail+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"ExerciseDetail";

@implementation ExerciseDetail (Management)

#pragma mark Insert methods

+ (ExerciseDetail *)exerciseWithExerciseId:(int32_t)exerciseId
                                  bodyZone:(NSString *)theBodyZone
                                   isSport:(NSString *)sport
                                     force:(NSString *)theForce
                                     guide:(NSString *)theGuide
                         photoFemaleMedium:(NSData *)thePhotoFemaleMedium
                          photoFemaleSmall:(NSData *)thePhotoFemaleSmall
                                 videoMale:(NSData *)theVideoMale
                               videoFemale:(NSData *)theVideoFemale
{
    ExerciseDetail *newExercise = (ExerciseDetail *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

    [newExercise updateWithExerciseId:exerciseId
                             bodyZone:theBodyZone
                              isSport:sport
                                force:theForce
                                guide:theGuide
                    photoFemaleMedium:thePhotoFemaleMedium
                     photoFemaleSmall:thePhotoFemaleSmall
                            videoMale:theVideoMale
                          videoFemale:theVideoFemale];

    commitDefaultMOC();
    return newExercise;
}

- (void)updateWithDictionary:(NSDictionary *)exerciseDict
{
    [self updateWithExerciseId:[[exerciseDict objectForKey:@"id"] intValue]
                          bodyZone:[exerciseDict objectForKey:@"bodyZone"]
                       isSport:[exerciseDict objectForKey:@"isSport"]
                   force:[exerciseDict objectForKey:@"force"]
                      guide:[exerciseDict objectForKey:@"guide"]
                photoFemaleMedium:[exerciseDict objectForKey:@"photoFemaleMedium"]
              photoFemaleSmall:[exerciseDict objectForKey:@"photoFemaleSmall"]
                     videoMale:[exerciseDict objectForKey:@"videoMale"]
                   videoFemale:[exerciseDict objectForKey:@"videoFemale"]];

    commitDefaultMOC();
}
/*
- (void)updateModelInDB
{
    commitDefaultMOC();
}
*/
+ (ExerciseDetail*)updateExerciseWithId:(int)exerciseId withDictionary:(NSDictionary*)exerciseDict
{
    ExerciseDetail *exercise = [ExerciseDetail getExerciseDetailInfo:exerciseId];

    if(exercise != nil) {

        // Update register
        [exercise updateWithDictionary:exerciseDict];

    } else {

        // Insert register
        exercise = [ExerciseDetail exerciseWithExerciseId:[[exerciseDict objectForKey:@"id"] intValue]
                                                 bodyZone:[exerciseDict objectForKey:@"bodyZone"]
                                                  isSport:[exerciseDict objectForKey:@"isSport"]
                                                    force:[exerciseDict objectForKey:@"force"]
                                                    guide:[exerciseDict objectForKey:@"guide"]
                                        photoFemaleMedium:[exerciseDict objectForKey:@"photoFemaleMedium"]
                                         photoFemaleSmall:[exerciseDict objectForKey:@"photoFemaleSmall"]
                                                videoMale:[exerciseDict objectForKey:@"videoMale"]
                                              videoFemale:[exerciseDict objectForKey:@"videoFemale"]];
    }

    return exercise;
}
/*
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
*/
+ (ExerciseDetail*)getExerciseDetailInfo:(int)exerciseId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId == %d", exerciseId];

  ExerciseDetail *exerciseInfo = (ExerciseDetail*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return exerciseInfo;
}
/*
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
*/

- (void)updateWithExerciseId:(int32_t)exerciseId
                    bodyZone:(NSString *)theBodyZone
                     isSport:(NSString *)sport
                       force:(NSString *)theForce
                       guide:(NSString *)theGuide
           photoFemaleMedium:(NSData *)thePhotoFemaleMedium
            photoFemaleSmall:(NSData *)thePhotoFemaleSmall
                   videoMale:(NSData *)theVideoMale
                 videoFemale:(NSData *)theVideoFemale
{
    self.exerciseId = exerciseId;
    self.bodyZone = theBodyZone;
    self.isSport = sport;
    self.force = theForce;
    self.exerciseDescription = theGuide;
    self.photoFemaleMedium = thePhotoFemaleMedium;
    self.photoFemaleSmall = thePhotoFemaleSmall;
    self.videoMale = theVideoMale;
    self.videoFemale = theVideoFemale;
}
/*
+ (NSArray *)getExercises
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId > %d", 0];

    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
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
*/

/*

#pragma mark Delete methods

+ (void) cleanDataToDate:(NSDate *)toDate
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUpdateDate < %@", toDate];
  
  deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());  
}
*/
@end
