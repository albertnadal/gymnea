//
//  ExerciseDetail+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExerciseDetail.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

typedef enum _GymneaExerciseImageOrder
{
    ExerciseImageFirst = 1,
    ExerciseImageSecond = 2
} GymneaExerciseImageOrder;

@interface ExerciseDetail (Management)

+ (ExerciseDetail *)exerciseWithExerciseId:(int32_t)exerciseId
                                  bodyZone:(NSString *)theBodyZone
                                   isSport:(NSString *)sport
                                     force:(NSString *)theForce
                                     guide:(NSString *)theGuide
                         photoFemaleMedium:(NSData *)thePhotoFemaleMedium
                          photoFemaleSmall:(NSData *)thePhotoFemaleSmall
                                 videoMale:(NSData *)theVideoMale
                               videoFemale:(NSData *)theVideoFemale
                                 videoLoop:(NSData *)theVideoLoop;

- (void)updateWithExerciseId:(int32_t)exerciseId
                    bodyZone:(NSString *)theBodyZone
                     isSport:(NSString *)sport
                       force:(NSString *)theForce
                       guide:(NSString *)theGuide
           photoFemaleMedium:(NSData *)thePhotoFemaleMedium
            photoFemaleSmall:(NSData *)thePhotoFemaleSmall
                 videoMale:(NSData *)theVideoMale
                 videoFemale:(NSData *)theVideoFemale
                   videoLoop:(NSData *)theVideoLoop;


- (void)updateWithPhotoMaleSmallSecond:(NSData *)photoSmall;

- (void)updateWithPhotoMaleMediumSecond:(NSData *)photoMedium;

- (void)updateWithPhotoFemaleSmall:(NSData *)photoSmall withOrder:(GymneaExerciseImageOrder)order;

- (void)updateWithPhotoFemaleMedium:(NSData *)photoMedium withOrder:(GymneaExerciseImageOrder)order;

- (void)updateWithVideoLoop:(NSData *)video;

/*
- (void)updateWithPhotoMedium:(NSData *)photoMedium;

- (void)updateWithPhotoSmall:(NSData *)photoSmall;

- (void)updateModelInDB;
*/
+ (ExerciseDetail*)updateExerciseWithId:(int)exerciseId
                         withDictionary:(NSDictionary*)exerciseDict;
/*
+ (Exercise*)updateExerciseImageWithId:(int)exerciseId withSize:(GymneaExerciseImageSize)size withImage:(UIImage *)image;
*/
- (void)updateWithDictionary:(NSDictionary *)exerciseDict;

+ (ExerciseDetail*)getExerciseDetailInfo:(int)exerciseId;
/*
+ (NSArray *)getExercises;

+ (NSArray *)getExercisesWithType:(GymneaExerciseType)exerciseTypeId
                       withMuscle:(GymneaMuscleType)muscleId
                    withEquipment:(GymneaEquipmentType)equipmentId
                        withLevel:(GymneaExerciseLevel)levelId
                         withName:(NSString *)searchText;
*/
@end
