//
//  GEADefinitions.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 12/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _GymneaMuscleType
{
    GymneaMuscleAny = 0,
    GymneaMuscleChest = 1,
    GymneaMuscleForearms = 2,
    GymneaMuscleLats = 3,
    GymneaMuscleMiddleBack = 4,
    GymneaMuscleLowerBack = 5,
    GymneaMuscleNeck = 6,
    GymneaMuscleQuadriceps = 7,
    GymneaMuscleHamstrings = 8,
    GymneaMuscleCalves = 9,
    GymneaMuscleTriceps = 10,
    GymneaMuscleTraps = 11,
    GymneaMuscleShoulders = 12,
    GymneaMuscleAbdominals = 13,
    GymneaMuscleGlutes = 14,
    GymneaMuscleBiceps = 15,
    GymneaMuscleAdductors = 17,
    GymneaMuscleAbductors = 18,
    GymneaMuscleCardio = 19,
    GymneaMuscleCervical = 20,
    GymneaMuscleDorsal = 21
} GymneaMuscleType;

typedef enum _GymneaExerciseType
{
    GymneaExerciseAny = 0,
    GymneaExerciseStrength = 1,
    GymneaExerciseCardio = 2,
    GymneaExerciseStretching = 3,
    GymneaExercisePlyometrics = 4,
    GymneaExerciseStrongman = 5,
    GymneaExerciseOlympicWeightlifting = 6,
    GymneaExercisePowerlifting = 7
} GymneaExerciseType;

typedef enum _GymneaEquipmentType
{
    GymneaEquipmentAny = 0,
    GymneaEquipmentDumbbell = 1,
    GymneaEquipmentBarbell = 2,
    GymneaEquipmentOther = 3,
    GymneaEquipmentCable = 4,
    GymneaEquipmentBodyOnly = 5,
    GymneaEquipmentMachine = 6,
    GymneaEquipmentExerciseBall = 7,
    GymneaEquipmentNone = 8,
    GymneaEquipmentBands = 9,
    GymneaEquipmentKettlebells = 10,
    GymneaEquipmentEZCurlBar = 11,
    GymneaEquipmentFoamRoll = 14,
    GymneaEquipmentMedicineBall = 15

} GymneaEquipmentType;

typedef enum _GymneaExerciseLevel
{
    GymneaExerciseLevelAny = 0,
    GymneaExerciseEasy = 1,
    GymneaExerciseIntermediate = 2,
    GymneaExerciseExpert = 3,
} GymneaExerciseLevel;

typedef enum _GymneaWorkoutType
{
    GymneaWorkoutAny = 0,
    GymneaWorkoutBulking = 1,
    GymneaWorkoutCutting = 2,
    GymneaWorkoutGeneralFitness = 3,
    GymneaWorkoutSportSpecific = 4
} GymneaWorkoutType;

typedef enum _GymneaWorkoutLevel
{
    GymneaWorkoutLevelAny = 0,
    GymneaWorkoutEasy = 1,
    GymneaWorkoutIntermediate = 2,
    GymneaWorkoutExpert = 3,
} GymneaWorkoutLevel;

extern NSString * const GEAMuscleChest;
extern NSString * const GEAMuscleForearms;
extern NSString * const GEAMuscleLats;
extern NSString * const GEAMuscleMiddleBack;
extern NSString * const GEAMuscleLowerBack;
extern NSString * const GEAMuscleNeck;
extern NSString * const GEAMuscleQuadriceps;
extern NSString * const GEAMuscleHamstrings;
extern NSString * const GEAMuscleCalves;
extern NSString * const GEAMuscleTriceps;
extern NSString * const GEAMuscleTraps;
extern NSString * const GEAMuscleShoulders;
extern NSString * const GEAMuscleAbdominals;
extern NSString * const GEAMuscleGlutes;
extern NSString * const GEAMuscleBiceps;
extern NSString * const GEAMuscleAdductors;
extern NSString * const GEAMuscleAbductors;
extern NSString * const GEAMuscleCardio;
extern NSString * const GEAMuscleCervical;
extern NSString * const GEAMuscleDorsal;

extern NSString * const GEAExerciseStrength;
extern NSString * const GEAExerciseCardio;
extern NSString * const GEAExerciseStretching;
extern NSString * const GEAExercisePlyometrics;
extern NSString * const GEAExerciseStrongman;
extern NSString * const GEAExerciseOlympicWeightlifting;
extern NSString * const GEAExercisePowerlifting;

extern NSString * const GEAEquipmentDumbbell;
extern NSString * const GEAEquipmentBarbell;
extern NSString * const GEAEquipmentOther;
extern NSString * const GEAEquipmentCable;
extern NSString * const GEAEquipmentBodyOnly;
extern NSString * const GEAEquipmentMachine;
extern NSString * const GEAEquipmentExerciseBall;
extern NSString * const GEAEquipmentNone;
extern NSString * const GEAEquipmentBands;
extern NSString * const GEAEquipmentKettlebells;
extern NSString * const GEAEquipmentEZCurlBar;
extern NSString * const GEAEquipmentFoamRoll;
extern NSString * const GEAEquipmentMedicineBall;

extern NSString * const GEAExerciseEasy;
extern NSString * const GEAExerciseIntermediate;
extern NSString * const GEAExerciseExpert;

extern NSString * const GEAExerciseColorOrange;
extern NSString * const GEAExerciseColorYellow;
extern NSString * const GEAExerciseColorPink;
extern NSString * const GEAExerciseColorPurple;
extern NSString * const GEAExerciseColorLightBlue;
extern NSString * const GEAExerciseColorGreen;
extern NSString * const GEAExerciseColorRed;

extern NSString * const GEAWorkoutBulking;
extern NSString * const GEAWorkoutCutting;
extern NSString * const GEAWorkoutGeneralFitness;
extern NSString * const GEAWorkoutSportSpecific;

extern NSString * const GEAWorkoutEasy;
extern NSString * const GEAWorkoutIntermediate;
extern NSString * const GEAWorkoutExpert;

extern NSString * const GEANotificationUserInfoUpdated;
extern NSString * const GEANotificationExercisesDownloadedUpdated;
extern NSString * const GEANotificationWorkoutsDownloadedUpdated;
extern NSString * const GEANotificationFavoriteWorkoutsUpdated;

extern NSTimeInterval const GEATimeIntervalBetweenDataUpdates;


@interface GEADefinitions : NSObject

+ (NSString *)retrieveTitleForMuscle:(GymneaMuscleType)muscleId;
+ (NSString *)retrieveTitleForExerciseType:(GymneaExerciseType)typeId;
+ (NSString *)retrieveTitleForEquipment:(GymneaEquipmentType)equipmentId;
+ (NSString *)retrieveTitleForExerciseLevel:(GymneaExerciseLevel)levelId;
+ (UIColor *)retrieveColorForExerciseType:(GymneaExerciseType)typeId;
+ (NSString *)retrieveTitleForWorkoutType:(GymneaWorkoutType)typeId;
+ (NSString *)retrieveTitleForWorkoutLevel:(GymneaWorkoutLevel)levelId;
+ (UIColor *)retrieveColorForWorkoutType:(GymneaWorkoutType)typeId;
+ (int)retrieveTotalExerciseTypes;
+ (NSDictionary *)retrieveExerciseTypesDictionary;
+ (int)retrieveTotalMuscles;
+ (NSDictionary *)retrieveMusclesDictionary;
+ (int)retrieveTotalEquipments;
+ (NSDictionary *)retrieveEquipmentsDictionary;
+ (int)retrieveTotalExerciseLevels;
+ (NSDictionary *)retrieveExerciseLevelsDictionary;
+ (int)retrieveTotalWorkoutTypes;
+ (NSDictionary *)retrieveWorkoutTypesDictionary;
+ (int)retrieveTotalWorkoutLevels;
+ (NSDictionary *)retrieveWorkoutLevelsDictionary;

@end
