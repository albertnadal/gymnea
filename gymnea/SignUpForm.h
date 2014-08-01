//
//  BookDetails.h
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _QuestionaireAnswer
{
    QuestionaireAnswerNO = 0,
    QuestionaireAnswerYes = 1,
    QuestionaireAnswerUnknown = 2
} QuestionaireAnswer;

typedef enum _FitnessGoalAnswer
{
    FitnessGoalAnswerNoGoal = 0,
    FitnessGoalAnswerGetLean = 1,
    FitnessGoalAnswerBurnFat = 2,
    FitnessGoalAnswerMuscleBuilding = 3,
    FitnessGoalAnswerIncreaseStrength = 4
} FitnessGoalAnswer;

@interface SignUpForm : NSObject

@property (nonatomic) QuestionaireAnswer doYouWearActivityTracker;
@property (nonatomic) QuestionaireAnswer doYouGoToGym;
@property (nonatomic) QuestionaireAnswer areYouFamiliarWithVideoconference;
@property (nonatomic) FitnessGoalAnswer fitnessGoal;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) float weight;
@property (nonatomic) BOOL weightIsMetricUnits;
@property (nonatomic) int heightCentimeters;
@property (nonatomic) int heightFoot;
@property (nonatomic) int heightInches;
@property (nonatomic) BOOL heightIsMetricUnits;


- (id)initWithName:(NSString *)theName
          lastName:(NSString *)theLastName
      emailAddress:(NSString *)theEmail
          password:(NSString *)thePassword
            gender:(NSString *)theGender
               day:(int)theDay
             month:(int)theMonth
            weight:(int)theYear
            weight:(int)theWeight
    weightIsMetric:(BOOL)theWeightIsMetric
       centimeters:(int)theCentimeters
              foot:(int)theFoot
            inches:(int)theInches
            height:(int)theHeight
    heightIsMetric:(BOOL)theHeightIsMetric
 wearTrackerAnswer:(QuestionaireAnswer)wearTracker
     goToGymAnswer:(QuestionaireAnswer)goToGym
          useVideo:(QuestionaireAnswer)useVideoconference
       fitnessGoal:(FitnessGoalAnswer)theGoal;

@end
