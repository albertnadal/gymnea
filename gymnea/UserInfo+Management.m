//
//  UserInfo+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "UserInfo+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"UserInfo";

@implementation UserInfo (Management)

#pragma mark Insert methods

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
                     workoutId:(int32_t)workoutId
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
                         birthDate:birthDate
                         workoutId:workoutId];

  commitDefaultMOC();
  return newUserInfo;
}

- (void)updateWithDictionary:(NSDictionary *)userInfoDict
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[userInfoDict objectForKey:@"day"] intValue]];
    [components setMonth:[[userInfoDict objectForKey:@"month"] intValue]];
    [components setYear:[[userInfoDict objectForKey:@"year"] intValue]];

    [self updateWithFirstName:[userInfoDict objectForKey:@"firstname"]
                     lastName:[userInfoDict objectForKey:@"lastname"]
                       gender:[userInfoDict objectForKey:@"gender"]
                        email:[userInfoDict objectForKey:@"email"]
            heightCentimeters:[[userInfoDict objectForKey:@"centimeters"] floatValue]
               heightIsMetric:[[userInfoDict objectForKey:@"heightIsMetric"] boolValue]
              weightKilograms:[[userInfoDict objectForKey:@"kilograms"] floatValue]
               weightIsMetric:[[userInfoDict objectForKey:@"weightIsMetric"] boolValue]
                      picture:[userInfoDict objectForKey:@"picture"]
                    birthDate:[calendar dateFromComponents:components]
                    workoutId:[[userInfoDict objectForKey:@"currentWorkoutId"] intValue]];

    commitDefaultMOC();
}

- (void)updateModelInDB
{
    commitDefaultMOC();
}

+ (UserInfo*)updateUserInfoWithEmail:(NSString *)email withDictionary:(NSDictionary*)userInfoDict
{
    UserInfo *userInfo = [UserInfo getUserInfo:email];

    if(userInfo != nil) {

        // Update register
        [userInfo updateWithDictionary:userInfoDict];

    } else {

        // Insert register
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[[userInfoDict objectForKey:@"day"] intValue]];
        [components setMonth:[[userInfoDict objectForKey:@"month"] intValue]];
        [components setYear:[[userInfoDict objectForKey:@"year"] intValue]];

        userInfo = [UserInfo userInfoWithEmail:[userInfoDict objectForKey:@"email"]
                                     firstName:[userInfoDict objectForKey:@"firstname"]
                                      lastName:[userInfoDict objectForKey:@"lastname"]
                                        gender:[userInfoDict objectForKey:@"gender"]
                             heightCentimeters:[[userInfoDict objectForKey:@"centimeters"] floatValue]
                                heightIsMetric:[[userInfoDict objectForKey:@"heightIsMetric"] boolValue]
                               weightKilograms:[[userInfoDict objectForKey:@"kilograms"] floatValue]
                                weightIsMetric:[[userInfoDict objectForKey:@"weightIsMetric"] boolValue]
                                       picture:[userInfoDict objectForKey:@"picture"]
                                     birthDate:[calendar dateFromComponents:components]
                                     workoutId:[[userInfoDict objectForKey:@"currentWorkoutId"] intValue]];

    }

    return userInfo;
}

+ (UserInfo*)updateUserPictureWithEmail:(NSString *)email withImage:(UIImage *)image
{
    UserInfo *userInfo = [UserInfo getUserInfo:email];
    
    if(userInfo != nil) {
        // Update register
        [userInfo setPicture:UIImagePNGRepresentation(image)];

        commitDefaultMOC();
    }

    return userInfo;
}

#pragma mark Select methods

+ (UserInfo *)getUserInfo:(NSString *)email
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];

  UserInfo *userInfo = (UserInfo*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return userInfo;
}

- (void)updateWithFirstName:(NSString*)firstName
                   lastName:(NSString*)lastName
                     gender:(NSString*)gender
                      email:(NSString*)email
          heightCentimeters:(float)heightCentimeters
             heightIsMetric:(BOOL)heightIsMetric
            weightKilograms:(float)weightKilograms
             weightIsMetric:(BOOL)weightIsMetric
                    picture:(NSData*)picture
                  birthDate:(NSDate*)birthDate
                  workoutId:(int32_t)workoutId
{
  self.firstName = firstName;
  self.lastName = lastName;
  self.gender = gender;
  self.email = email;
  self.heightCentimeters = heightCentimeters;
  self.heightIsMetric = heightIsMetric;
  self.weightKilograms = weightKilograms;
  self.weightIsMetric = weightIsMetric;
  self.picture = picture;
  self.birthDate = birthDate;
  self.currentWorkoutId = workoutId;
}

- (BOOL)hasCurrentWorkout
{
    return (self.currentWorkoutId != 0);
}

- (Workout *)getUserCurrentWorkout
{
    if(![self hasCurrentWorkout]) {
        return nil;
    }

    NSLog(@"Get current workout id: %d", self.currentWorkoutId);

    return [Workout getWorkoutInfo:self.currentWorkoutId];
}

+ (void)deleteAll
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email != %@", @""];
    
    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

@end
