//
//  SignUpInForm.m
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "SignUpForm.h"

@implementation SignUpForm

@synthesize firstName;
@synthesize lastName;
@synthesize emailAddress;
@synthesize password;
@synthesize gender;
@synthesize day;
@synthesize month;
@synthesize year;
@synthesize weight;
@synthesize weightIsMetricUnits;
@synthesize heightCentimeters;
@synthesize heightFoot;
@synthesize heightInches;
@synthesize heightIsMetricUnits;
@synthesize doYouWearActivityTracker;
@synthesize doYouGoToGym;
@synthesize areYouFamiliarWithVideoconference;
@synthesize fitnessGoal;


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
       fitnessGoal:(FitnessGoalAnswer)theGoal
{
    self = [super init];
    if(self)
    {
        [self setFirstName:theName];
        [self setLastName:theLastName];
        [self setEmailAddress:theEmail];
        [self setPassword:thePassword];
        [self setGender:theGender];
        [self setDay:theDay];
        [self setMonth:theMonth];
        [self setYear:theYear];
        [self setWeight:theWeight];
        [self setWeightIsMetricUnits:theWeightIsMetric];
        [self setHeightCentimeters:theCentimeters];
        [self setHeightFoot:theFoot];
        [self setHeightInches:theInches];
        [self setHeightIsMetricUnits:theHeightIsMetric];
        [self setDoYouWearActivityTracker:wearTracker];
        [self setDoYouGoToGym:goToGym];
        [self setAreYouFamiliarWithVideoconference:useVideoconference];
        [self setFitnessGoal:theGoal];
    }

    return self;
}

@end
