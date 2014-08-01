//
//  SignUpInForm.m
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "SignUpInForm.h"

@implementation SignUpInForm

@synthesize firstName;
@synthesize lastName;
@synthesize emailAddress;
@synthesize password;
@synthesize age;
@synthesize weight;
@synthesize height;
@synthesize doYouWearActivityTracker;
@synthesize doYouGoToGym;
@synthesize areYouFamiliarWithVideoconference;
@synthesize fitnessGoal;

- (id)initWithName:(NSString *)theName
          lastName:(NSString *)theLastName
      emailAddress:(NSString *)theEmail
          password:(NSString *)thePassword
               age:(int)theAge
            weight:(int)theWeight
            height:(int)theHeight
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
        [self setAge:theAge];
        [self setWeight:theWeight];
        [self setHeight:theWeight];
        [self setDoYouWearActivityTracker:wearTracker];
        [self setDoYouGoToGym:goToGym];
        [self setAreYouFamiliarWithVideoconference:useVideoconference];
        [self setFitnessGoal:theGoal];
    }

    return self;
}

@end
