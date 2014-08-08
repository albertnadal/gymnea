//
//  UserInfo+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "UserInfo.h"

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
                     birthDate:(NSDate*)birthDate;

- (void)updateWithFirstName:(NSString*)firstName
                   lastName:(NSString*)lastName
                     gender:(NSString*)gender
                      email:(NSString*)email
          heightCentimeters:(float)heightCentimeters
             heightIsMetric:(BOOL)heightIsMetric
            weightKilograms:(float)weightKilograms
             weightIsMetric:(BOOL)weightIsMetric
                  birthDate:(NSDate*)birthDate;

- (void)updateWithDictionary:(NSDictionary *)userInfoDict;

- (void)updateModelInDB;

+ (UserInfo*)updateUserInfoWithEmail:(NSString *)email withDictionary:(NSDictionary*)userInfoDict;

/** Creates a new, featured, event with the information got from the featuredList api method */
//+ (UserInfo*) featuredEvent:(NSDictionary*) featuredEventDictionary;

/** Returns the event with id eventId. If there isn't such event or there are more than one it returns nil
 
 @param eventId The id of the event we want to retrieve */
 
+ (UserInfo*)getUserInfo:(NSString*)email;

/** It sets all the existing events as not featured
 
 It's necessary, for example, before setting the new featured events */
//+ (void) resetFeaturedEvents;

/** Returns an array with the featuredEvents stored in CoreData. If there aren't returns an empty array */
//+ (NSArray*) getFeaturedEvents;

/** Delete all data from Event entity which lastUpdateDate is prior to toDate
 
 @param toDate oldest lastUpdateDate that we keep */
//+ (void) cleanDataToDate:(NSDate*) toDate;

/** Updates the event with the information of the JSON response of the event details backend api
 
 @param eventDictionary NSDictionary with all the information to create the event */
//- (void) updateWithEventDictionary:(NSDictionary*) eventDictionary;

/** Updates the event with the information of the JSON response of the featured events backend api
 
 @param featuredEventDictionary NSDictionary with the featured event information (it's not complete information) */
//- (void) updateWithFeaturedEventDictionary:(NSDictionary*) featuredEventDictionary;

@end
