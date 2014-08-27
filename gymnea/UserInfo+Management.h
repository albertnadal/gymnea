//
//  UserInfo+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "UserInfo.h"
#import <UIKit/UIKit.h>
#import "Workout+Management.h"

/** Management methods for Event entity */

@interface UserInfo (Management)

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
                     workoutId:(int32_t)workoutId;

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
                  workoutId:(int32_t)workoutId;

- (void)updateWithDictionary:(NSDictionary *)userInfoDict;

- (void)updateModelInDB;

+ (UserInfo*)updateUserInfoWithEmail:(NSString *)email withDictionary:(NSDictionary*)userInfoDict;

+ (UserInfo*)updateUserPictureWithEmail:(NSString *)email withImage:(UIImage *)image;

+ (UserInfo*)getUserInfo:(NSString*)email;

- (BOOL)hasCurrentWorkout;

- (Workout *)getUserCurrentWorkout;

@end
