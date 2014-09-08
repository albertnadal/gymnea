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
                                 videoLoop:(NSData *)theVideoLoop
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
                          videoFemale:theVideoFemale
                            videoLoop:theVideoLoop];

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
                   videoFemale:[exerciseDict objectForKey:@"videoFemale"]
                     videoLoop:[exerciseDict objectForKey:@"videoLoop"]];

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
                                              videoFemale:[exerciseDict objectForKey:@"videoFemale"]
                                                videoLoop:[exerciseDict objectForKey:@"videoLoop"]];
    }

    return exercise;
}

+ (ExerciseDetail*)getExerciseDetailInfo:(int)exerciseId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId == %d", exerciseId];

  ExerciseDetail *exerciseInfo = (ExerciseDetail*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return exerciseInfo;
}

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

- (void)updateWithExerciseId:(int32_t)exerciseId
                    bodyZone:(NSString *)theBodyZone
                     isSport:(NSString *)sport
                       force:(NSString *)theForce
                       guide:(NSString *)theGuide
           photoFemaleMedium:(NSData *)thePhotoFemaleMedium
            photoFemaleSmall:(NSData *)thePhotoFemaleSmall
                   videoMale:(NSData *)theVideoMale
                 videoFemale:(NSData *)theVideoFemale
                   videoLoop:(NSData *)theVideoLoop
{
    self.exerciseId = exerciseId;
    self.bodyZone = theBodyZone;
    self.isSport = sport;
    self.force = theForce;
    self.exerciseDescription = theGuide;
    self.photoFemaleMediumFirst = thePhotoFemaleMedium;
    self.photoFemaleSmallFirst = thePhotoFemaleSmall;
    self.videoMale = theVideoMale;
    self.videoFemale = theVideoFemale;
    self.videoLoop = theVideoLoop;
}

#pragma mark Delete methods

+ (void)deleteAll
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exerciseId >= 0"];
    
    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

@end
