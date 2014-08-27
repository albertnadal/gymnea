//
//  GEADefinitions.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 12/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GEADefinitions.h"

NSString * const GEAMuscleChest = @"Chest";
NSString * const GEAMuscleForearms = @"Forearms";
NSString * const GEAMuscleLats = @"Lats";
NSString * const GEAMuscleMiddleBack = @"Middle Back";
NSString * const GEAMuscleLowerBack = @"Lower Back";
NSString * const GEAMuscleNeck = @"Neck";
NSString * const GEAMuscleQuadriceps = @"Quadriceps";
NSString * const GEAMuscleHamstrings = @"Hamstrings";
NSString * const GEAMuscleCalves = @"Calves";
NSString * const GEAMuscleTriceps = @"Triceps";
NSString * const GEAMuscleTraps = @"Traps";
NSString * const GEAMuscleShoulders = @"Shoulders";
NSString * const GEAMuscleAbdominals = @"Abdominals";
NSString * const GEAMuscleGlutes = @"Glutes";
NSString * const GEAMuscleBiceps = @"Biceps";
NSString * const GEAMuscleAdductors = @"Adductors";
NSString * const GEAMuscleAbductors = @"Abductors";
NSString * const GEAMuscleCardio = @"Cardio";
NSString * const GEAMuscleCervical = @"Cervical";
NSString * const GEAMuscleDorsal = @"Dorsal";

NSString * const GEAExerciseStrength = @"Strength";
NSString * const GEAExerciseCardio = @"Cardio";
NSString * const GEAExerciseStretching = @"Stretching";
NSString * const GEAExercisePlyometrics = @"Plyometrics";
NSString * const GEAExerciseStrongman = @"Strongman";
NSString * const GEAExerciseOlympicWeightlifting = @"Olympic Weightlifting";
NSString * const GEAExercisePowerlifting = @"Powerlifting";

NSString * const GEAEquipmentDumbbell = @"Dumbbell";
NSString * const GEAEquipmentBarbell = @"Barbell";
NSString * const GEAEquipmentOther = @"Other";
NSString * const GEAEquipmentCable = @"Cable";
NSString * const GEAEquipmentBodyOnly = @"Body Only";
NSString * const GEAEquipmentMachine = @"Machine";
NSString * const GEAEquipmentExerciseBall = @"Exercise Ball";
NSString * const GEAEquipmentNone = @"None";
NSString * const GEAEquipmentBands = @"Bands";
NSString * const GEAEquipmentKettlebells = @"Kettlebells";
NSString * const GEAEquipmentEZCurlBar = @"E-Z Curl Bar";
NSString * const GEAEquipmentFoamRoll = @"Foam Roll";
NSString * const GEAEquipmentMedicineBall = @"Medicine Ball";

NSString * const GEAExerciseEasy = @"Easy";
NSString * const GEAExerciseIntermediate = @"Intermediate";
NSString * const GEAExerciseExpert = @"Expert";

NSString * const GEAExerciseColorOrange = @"#ed450c";
NSString * const GEAExerciseColorYellow = @"#ffb800";
NSString * const GEAExerciseColorPink = @"#fb226f";
NSString * const GEAExerciseColorPurple = @"#702583";
NSString * const GEAExerciseColorLightBlue = @"#14b9e8";
NSString * const GEAExerciseColorGreen = @"#6fae26";
NSString * const GEAExerciseColorRed = @"#e63131";

NSString * const GEAWorkoutBulking = @"Bulking";
NSString * const GEAWorkoutCutting = @"Cutting";
NSString * const GEAWorkoutGeneralFitness = @"General Fitness";
NSString * const GEAWorkoutSportSpecific = @"Sport Specific";

NSString * const GEAWorkoutEasy = @"Easy";
NSString * const GEAWorkoutIntermediate = @"Intermediate";
NSString * const GEAWorkoutExpert = @"Expert";

NSString * const GEANotificationUserInfoUpdated = @"GEANotificationUserInfoUpdated";

@interface GEADefinitions()

+ (UIColor *)colorWithHexColorString:(NSString*)inColorString withAlpha:(float)alpha;

@end

@implementation GEADefinitions

+ (NSString *)retrieveTitleForMuscle:(GymneaMuscleType)muscleId
{
    switch (muscleId) {
        case GymneaMuscleChest:         return GEAMuscleChest;
                                        break;

        case GymneaMuscleForearms:      return GEAMuscleForearms;
                                        break;
            
        case GymneaMuscleLats:          return GEAMuscleLats;
                                        break;
            
        case GymneaMuscleMiddleBack:    return GEAMuscleMiddleBack;
                                        break;
            
        case GymneaMuscleLowerBack:     return GEAMuscleLowerBack;
                                        break;
            
        case GymneaMuscleNeck:          return GEAMuscleNeck;
                                        break;
            
        case GymneaMuscleQuadriceps:    return GEAMuscleQuadriceps;
                                        break;
            
        case GymneaMuscleHamstrings:    return GEAMuscleHamstrings;
                                        break;
            
        case GymneaMuscleCalves:        return GEAMuscleCalves;
                                        break;
            
        case GymneaMuscleTriceps:       return GEAMuscleTriceps;
                                        break;
            
        case GymneaMuscleTraps:         return GEAMuscleTraps;
                                        break;
            
        case GymneaMuscleShoulders:     return GEAMuscleShoulders;
                                        break;
            
        case GymneaMuscleAbdominals:    return GEAMuscleAbdominals;
                                        break;
            
        case GymneaMuscleGlutes:        return GEAMuscleGlutes;
                                        break;
            
        case GymneaMuscleBiceps:        return GEAMuscleBiceps;
                                        break;
            
        case GymneaMuscleAdductors:     return GEAMuscleAdductors;
                                        break;
            
        case GymneaMuscleAbductors:     return GEAMuscleAbductors;
                                        break;
            
        case GymneaMuscleCardio:        return GEAMuscleCardio;
                                        break;
            
        case GymneaMuscleCervical:      return GEAMuscleCervical;
                                        break;
            
        case GymneaMuscleDorsal:        return GEAMuscleDorsal;
                                        break;

        default:                        break;
    }

    return @"";
}

+ (NSString *)retrieveTitleForExerciseType:(GymneaExerciseType)typeId
{

    switch (typeId) {
        case GymneaExerciseAny:                     return @"Any";
                                                    break;

        case GymneaExerciseStrength:                return GEAExerciseStrength;
                                                    break;

        case GymneaExerciseCardio:                  return GEAExerciseCardio;
                                                    break;

        case GymneaExerciseStretching:              return GEAExerciseStretching;
                                                    break;

        case GymneaExercisePlyometrics:             return GEAExercisePlyometrics;
                                                    break;

        case GymneaExerciseStrongman:               return GEAExerciseStrongman;
                                                    break;

        case GymneaExerciseOlympicWeightlifting:    return GEAExerciseOlympicWeightlifting;
                                                    break;

        case GymneaExercisePowerlifting:            return GEAExercisePowerlifting;
                                                    break;

        default:                        break;
    }
    
    return @"";
}

+ (NSString *)retrieveTitleForEquipment:(GymneaEquipmentType)equipmentId
{
    switch (equipmentId) {
        case GymneaEquipmentDumbbell:       return GEAEquipmentDumbbell;
                                            break;

        case GymneaEquipmentBarbell:        return GEAEquipmentBarbell;
                                            break;

        case GymneaEquipmentOther:          return GEAEquipmentOther;
                                            break;

        case GymneaEquipmentCable:          return GEAEquipmentCable;
                                            break;

        case GymneaEquipmentBodyOnly:       return GEAEquipmentBodyOnly;
                                            break;

        case GymneaEquipmentMachine:        return GEAEquipmentMachine;
                                            break;

        case GymneaEquipmentNone:           return GEAEquipmentNone;
                                            break;

        case GymneaEquipmentBands:          return GEAEquipmentBands;
                                            break;

        case GymneaEquipmentKettlebells:    return GEAEquipmentKettlebells;
                                            break;

        case GymneaEquipmentEZCurlBar:      return GEAEquipmentEZCurlBar;
                                            break;

        case GymneaEquipmentFoamRoll:       return GEAEquipmentFoamRoll;
                                            break;

        case GymneaEquipmentMedicineBall:   return GEAEquipmentMedicineBall;
                                            break;

        default:                            break;
    }

    return @"";
}

+ (NSString *)retrieveTitleForExerciseLevel:(GymneaExerciseLevel)levelId
{
    switch (levelId) {

        case GymneaExerciseEasy:            return GEAExerciseEasy;
                                            break;

        case GymneaExerciseIntermediate:    return GEAExerciseIntermediate;
                                            break;

        case GymneaExerciseExpert:          return GEAExerciseExpert;
                                            break;

        default:                            break;
    }

    return @"";
}

+ (UIColor *)retrieveColorForExerciseType:(GymneaExerciseType)typeId
{
    switch (typeId) {

        case GymneaExerciseStrength:                return [GEADefinitions colorWithHexColorString:GEAExerciseColorLightBlue withAlpha:0.2];
                                                    break;

        case GymneaExerciseCardio:                  return [GEADefinitions colorWithHexColorString:GEAExerciseColorOrange withAlpha:0.2];
                                                    break;

        case GymneaExerciseStretching:              return [GEADefinitions colorWithHexColorString:GEAExerciseColorGreen withAlpha:0.2];
                                                    break;

        case GymneaExercisePlyometrics:             return [GEADefinitions colorWithHexColorString:GEAExerciseColorPink withAlpha:0.2];
                                                    break;

        case GymneaExerciseStrongman:               return [GEADefinitions colorWithHexColorString:GEAExerciseColorRed withAlpha:0.2];
                                                    break;

        case GymneaExerciseOlympicWeightlifting:    return [GEADefinitions colorWithHexColorString:GEAExerciseColorYellow withAlpha:0.2];
                                                    break;

        case GymneaExercisePowerlifting:            return [GEADefinitions colorWithHexColorString:GEAExerciseColorPurple withAlpha:0.2];
                                                    break;
            
        default:                                    break;
    }

    return [UIColor whiteColor];
}

+ (NSString *)retrieveTitleForWorkoutType:(GymneaWorkoutType)typeId
{
    switch (typeId) {
        case GymneaWorkoutAny:                      return @"Any";
            break;
            
        case GymneaWorkoutBulking:                  return GEAWorkoutBulking;
            break;
            
        case GymneaWorkoutCutting:                  return GEAWorkoutCutting;
            break;
            
        case GymneaWorkoutGeneralFitness:           return GEAWorkoutGeneralFitness;
            break;
            
        case GymneaWorkoutSportSpecific:            return GEAWorkoutSportSpecific;
            break;

        default:                                    break;
    }
    
    return @"";
}

+ (NSString *)retrieveTitleForWorkoutLevel:(GymneaWorkoutLevel)levelId
{
    switch (levelId) {
            
        case GymneaWorkoutEasy:            return GEAWorkoutEasy;
            break;
            
        case GymneaWorkoutIntermediate:    return GEAWorkoutIntermediate;
            break;
            
        case GymneaWorkoutExpert:          return GEAWorkoutExpert;
            break;
            
        default:                            break;
    }
    
    return @"";
}

+ (UIColor *)retrieveColorForWorkoutType:(GymneaWorkoutType)typeId
{
    switch (typeId) {
            
        case GymneaWorkoutBulking:                  return [GEADefinitions colorWithHexColorString:GEAExerciseColorYellow withAlpha:0.2];
            break;
            
        case GymneaWorkoutCutting:                  return [GEADefinitions colorWithHexColorString:GEAExerciseColorRed withAlpha:0.2];
            break;
            
        case GymneaWorkoutGeneralFitness:           return [GEADefinitions colorWithHexColorString:GEAExerciseColorLightBlue withAlpha:0.2];
            break;
            
        case GymneaWorkoutSportSpecific:            return [GEADefinitions colorWithHexColorString:GEAExerciseColorOrange withAlpha:0.2];
            break;
            
        default:                                    break;
    }
    
    return [UIColor whiteColor];
}

+ (int)retrieveTotalExerciseTypes
{
    return 8; // including "Any" exercise type
}

+ (NSDictionary *)retrieveExerciseTypesDictionary
{
    return @{ [NSNumber numberWithInt:GymneaExerciseAny] : @"Any",
              [NSNumber numberWithInt:GymneaExerciseStrength] : GEAExerciseStrength,
              [NSNumber numberWithInt:GymneaExerciseCardio] : GEAExerciseCardio,
              [NSNumber numberWithInt:GymneaExerciseStretching] : GEAExerciseStretching,
              [NSNumber numberWithInt:GymneaExercisePlyometrics] : GEAExercisePlyometrics,
              [NSNumber numberWithInt:GymneaExerciseStrongman] : GEAExerciseStrongman,
              [NSNumber numberWithInt:GymneaExerciseOlympicWeightlifting] : GEAExerciseOlympicWeightlifting,
              [NSNumber numberWithInt:GymneaExercisePowerlifting] : GEAExercisePowerlifting };
}

+ (int)retrieveTotalMuscles
{
    return 21; // including "Any" muscle
}

+ (NSDictionary *)retrieveMusclesDictionary
{
    return @{ [NSNumber numberWithInt:GymneaMuscleAny] : @"Any",
              [NSNumber numberWithInt:GymneaMuscleChest] : GEAMuscleChest,
              [NSNumber numberWithInt:GymneaMuscleForearms] : GEAMuscleForearms,
              [NSNumber numberWithInt:GymneaMuscleLats] : GEAMuscleLats,
              [NSNumber numberWithInt:GymneaMuscleMiddleBack] : GEAMuscleMiddleBack,
              [NSNumber numberWithInt:GymneaMuscleLowerBack] : GEAMuscleLowerBack,
              [NSNumber numberWithInt:GymneaMuscleNeck] : GEAMuscleNeck,
              [NSNumber numberWithInt:GymneaMuscleQuadriceps] : GEAMuscleQuadriceps,
              [NSNumber numberWithInt:GymneaMuscleHamstrings] : GEAMuscleHamstrings,
              [NSNumber numberWithInt:GymneaMuscleCalves] : GEAMuscleCalves,
              [NSNumber numberWithInt:GymneaMuscleTriceps] : GEAMuscleTriceps,
              [NSNumber numberWithInt:GymneaMuscleTraps] : GEAMuscleTraps,
              [NSNumber numberWithInt:GymneaMuscleShoulders] : GEAMuscleShoulders,
              [NSNumber numberWithInt:GymneaMuscleAbdominals] : GEAMuscleAbdominals,
              [NSNumber numberWithInt:GymneaMuscleGlutes] : GEAMuscleGlutes,
              [NSNumber numberWithInt:GymneaMuscleBiceps] : GEAMuscleBiceps,
              [NSNumber numberWithInt:GymneaMuscleAdductors] : GEAMuscleAdductors,
              [NSNumber numberWithInt:GymneaMuscleAbductors] : GEAMuscleAbductors,
              [NSNumber numberWithInt:GymneaMuscleCardio] : GEAMuscleCardio,
              [NSNumber numberWithInt:GymneaMuscleCervical] : GEAMuscleCervical,
              [NSNumber numberWithInt:GymneaMuscleDorsal] : GEAMuscleDorsal };
}

+ (int)retrieveTotalEquipments
{
    return 14; // including "Any" equipment
}

+ (NSDictionary *)retrieveEquipmentsDictionary
{

    return @{ [NSNumber numberWithInt:GymneaEquipmentAny] : @"Any",
              [NSNumber numberWithInt:GymneaEquipmentDumbbell] : GEAEquipmentDumbbell,
              [NSNumber numberWithInt:GymneaEquipmentBarbell] : GEAEquipmentBarbell,
              [NSNumber numberWithInt:GymneaEquipmentOther] : GEAEquipmentOther,
              [NSNumber numberWithInt:GymneaEquipmentCable] : GEAEquipmentCable,
              [NSNumber numberWithInt:GymneaEquipmentBodyOnly] : GEAEquipmentBodyOnly,
              [NSNumber numberWithInt:GymneaEquipmentMachine] : GEAEquipmentMachine,
              [NSNumber numberWithInt:GymneaEquipmentExerciseBall] : GEAEquipmentExerciseBall,
              [NSNumber numberWithInt:GymneaEquipmentNone] : GEAEquipmentNone,
              [NSNumber numberWithInt:GymneaEquipmentBands] : GEAEquipmentBands,
              [NSNumber numberWithInt:GymneaEquipmentKettlebells] : GEAEquipmentKettlebells,
              [NSNumber numberWithInt:GymneaEquipmentEZCurlBar] : GEAEquipmentEZCurlBar,
              [NSNumber numberWithInt:GymneaEquipmentFoamRoll] : GEAEquipmentFoamRoll,
              [NSNumber numberWithInt:GymneaEquipmentMedicineBall] : GEAEquipmentMedicineBall };
}

+ (int)retrieveTotalExerciseLevels
{
    return 4; // including "Any" level
}

+ (NSDictionary *)retrieveExerciseLevelsDictionary
{
    return @{ [NSNumber numberWithInt:GymneaExerciseLevelAny] : @"Any",
              [NSNumber numberWithInt:GymneaExerciseEasy] : GEAExerciseEasy,
              [NSNumber numberWithInt:GymneaExerciseIntermediate] : GEAExerciseIntermediate,
              [NSNumber numberWithInt:GymneaExerciseExpert] : GEAExerciseExpert };
}

+ (int)retrieveTotalWorkoutTypes
{
    return 5; // including "Any" workout type
}

+ (NSDictionary *)retrieveWorkoutTypesDictionary
{
    return @{ [NSNumber numberWithInt:GymneaWorkoutAny] : @"Any",
              [NSNumber numberWithInt:GymneaWorkoutBulking] : GEAWorkoutBulking,
              [NSNumber numberWithInt:GymneaWorkoutCutting] : GEAWorkoutCutting,
              [NSNumber numberWithInt:GymneaWorkoutGeneralFitness] : GEAWorkoutGeneralFitness,
              [NSNumber numberWithInt:GymneaWorkoutSportSpecific] : GEAWorkoutSportSpecific };
}

+ (int)retrieveTotalWorkoutLevels
{
    return 4; // including "Any" level
}

+ (NSDictionary *)retrieveWorkoutLevelsDictionary
{
    return @{ [NSNumber numberWithInt:GymneaWorkoutLevelAny] : @"Any",
              [NSNumber numberWithInt:GymneaWorkoutEasy] : GEAWorkoutEasy,
              [NSNumber numberWithInt:GymneaWorkoutIntermediate] : GEAWorkoutIntermediate,
              [NSNumber numberWithInt:GymneaWorkoutExpert] : GEAWorkoutExpert };
}

+ (UIColor *)colorWithHexColorString:(NSString*)hexString withAlpha:(float)alpha
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

@end
