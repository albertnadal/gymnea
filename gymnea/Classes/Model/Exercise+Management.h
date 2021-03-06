//
//  Exercise+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "Exercise.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

typedef enum _GymneaExerciseImageSize
{
    ExerciseImageSizeSmall = 0,
    ExerciseImageSizeMedium = 1
} GymneaExerciseImageSize;

typedef enum _GymneaExerciseImageGender
{
    ExerciseImageMale = 0,
    ExerciseImageFemale = 1
} GymneaExerciseImageGender;

@interface Exercise (Management)

+ (Exercise *)exerciseWithExerciseId:(int32_t)exerciseId
                                name:(NSString *)name
                             isSaved:(BOOL)saved
                         equipmentId:(int32_t)equipmentId
                            muscleId:(int32_t)muscleId
                              typeId:(int32_t)typeId
                             levelId:(int32_t)levelId
                         photoMedium:(NSData*)photoMedium
                          photoSmall:(NSData*)photoSmall;

- (void)updateWithExerciseId:(int32_t)exerciseId
                        name:(NSString *)name
                     isSaved:(BOOL)saved
                 equipmentId:(int32_t)equipmentId
                    muscleId:(int32_t)muscleId
                      typeId:(int32_t)typeId
                     levelId:(int32_t)levelId
                 photoMedium:(NSData*)photoMedium
                  photoSmall:(NSData*)photoSmall;

- (void)updateWithPhotoMedium:(NSData *)photoMedium;

- (void)updateWithPhotoSmall:(NSData *)photoSmall;

- (void)updateModelInDB;

- (void)updateWithDictionary:(NSDictionary *)exerciseDict;

+ (Exercise*)updateExerciseWithId:(int)exerciseId withDictionary:(NSDictionary*)exerciseDict;

+ (Exercise*)updateExerciseImageWithId:(int)exerciseId
                              withSize:(GymneaExerciseImageSize)size
                             withImage:(UIImage *)image;

+ (Exercise*)getExerciseInfo:(int)exerciseId;

+ (NSArray *)getExercises;

+ (NSArray *)getSavedExercises;

+ (NSArray *)getDownloadedExercises;

+ (NSArray *)getExercisesWithType:(GymneaExerciseType)exerciseTypeId
                       withMuscle:(GymneaMuscleType)muscleId
                    withEquipment:(GymneaEquipmentType)equipmentId
                        withLevel:(GymneaExerciseLevel)levelId
                         withName:(NSString *)searchText;

+ (NSArray *)getExercisesWithType:(GymneaExerciseType)exerciseTypeId
                       withMuscle:(GymneaMuscleType)muscleId
                    withEquipment:(GymneaEquipmentType)equipmentId
                        withLevel:(GymneaExerciseLevel)levelId
                         withName:(NSString *)searchText
                  withExerciseIds:(NSArray *)exerciseIds;

+ (NSArray *)getSavedExercisesWithType:(GymneaExerciseType)exerciseTypeId
                            withMuscle:(GymneaMuscleType)muscleId
                         withEquipment:(GymneaEquipmentType)equipmentId
                             withLevel:(GymneaExerciseLevel)levelId
                              withName:(NSString *)searchText;

+ (void)deleteAll;

@end
