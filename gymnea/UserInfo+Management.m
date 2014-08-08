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
                     birthDate:(NSDate*)birthDate
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
                         birthDate:birthDate];

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
                    birthDate:[calendar dateFromComponents:components]];

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
                                     birthDate:[calendar dateFromComponents:components]];

    }

    return userInfo;
}

/*
+ (UserInfo*) featuredEvent:(NSDictionary *)featuredEventDictionary
{
  NSDictionary *eventVenue = [featuredEventDictionary objectForKey:@"eventVenue"];
  
  Event *event = [Event eventWithId:[featuredEventDictionary objectForKey:@"id"]
                   eventDescription:nil
                              title:[featuredEventDictionary objectForKey:@"title"]
                           featured:YES
                 imageHorizontalUrl:[featuredEventDictionary objectForKey:@"imageHorizontalUrl"]
                   imageVerticalUrl:[featuredEventDictionary objectForKey:@"imageVerticalUrl"]
                     imageSquareUrl:[featuredEventDictionary objectForKey:@"imageSquareUrl"]
                        imageBigUrl:[featuredEventDictionary objectForKey:@"imageBigUrl"]
                     ageRestriction:0
                             rating:0
                            venueId:0
                          venueName:[eventVenue objectForKey:@"name"]
                       venueCountry:nil
                          venueCity:nil
                        venueStreet:nil
            venueCoordinateLatitude:0
           venueCoordinateLongitude:0
                         venueState:nil
                        priceLowest:[[featuredEventDictionary objectForKey:@"priceLowest"] floatValue]
                       priceHighest:[[featuredEventDictionary objectForKey:@"priceLowest"] floatValue]];
  
  return event;
}
*/
#pragma mark Select methods

+ (UserInfo *)getUserInfo:(NSString *)email
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];

  UserInfo *userInfo = (UserInfo*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return userInfo;
}
/*
+ (NSArray*) getFeaturedEvents
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"featured == %d", YES];
  
  return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

#pragma mark Update methods

+ (void) resetFeaturedEvents
{
  NSArray *featuredEvents = [Event getFeaturedEvents];
  for (Event *event in featuredEvents)
    event.featured = NO;
  
  commitDefaultMOC();
}

- (void) updateWithEventDictionary:(NSDictionary *)eventDictionary
{
  NSDictionary *yelpInfo = [eventDictionary objectForKey:@"yelpInfo"];
  NSDictionary *eventVenue = [eventDictionary objectForKey:@"eventVenue"];
  
  [self updateWithDescription:[eventDictionary objectForKey:@"description"]
                        title:[eventDictionary objectForKey:@"title"]
                     featured:[[eventDictionary objectForKey:@"featured"] boolValue]
           imageHorizontalUrl:[eventDictionary objectForKey:@"imageHorizontalUrl"]
             imageVerticalUrl:[eventDictionary objectForKey:@"imageVerticalUrl"]
               imageSquareUrl:[eventDictionary objectForKey:@"imageSquareUrl"]
                  imageBigUrl:[eventDictionary objectForKey:@"imageBigUrl"]
               ageRestriction:[[eventDictionary objectForKey:@"ageRestriction"] unsignedIntegerValue]
                       rating:[[yelpInfo objectForKey:@"rating"] unsignedIntegerValue]
                      venueId:[[eventDictionary objectForKey:@"venueId"] unsignedIntegerValue]
                    venueName:[eventVenue objectForKey:@"name"]
                 venueCountry:[eventVenue objectForKey:@"country"]
                    venueCity:[eventVenue objectForKey:@"city"]
                  venueStreet:[eventVenue objectForKey:@"street"]
      venueCoordinateLatitude:[[eventVenue objectForKey:@"coordinateLatitude"] doubleValue]
     venueCoordinateLongitude:[[eventVenue objectForKey:@"coordinateLongitude"] doubleValue]
                   venueState:[eventVenue objectForKey:@"venueState"]
                  priceLowest:[[eventDictionary objectForKey:@"priceLowest"] floatValue]
                 priceHighest:[[eventDictionary objectForKey:@"priceLowest"] floatValue]];
  
  commitDefaultMOC();
}

- (void) updateWithFeaturedEventDictionary:(NSDictionary *)featuredEventDictionary
{
  NSDictionary *eventVenue = [featuredEventDictionary objectForKey:@"eventVenue"];
  
  self.featured = YES;
  self.title = [featuredEventDictionary objectForKey:@"title"];
  self.imageHorizontalUrl = [featuredEventDictionary objectForKey:@"imageHorizontalUrl"];
  self.imageVerticalUrl = [featuredEventDictionary objectForKey:@"imageVerticallUrl"];
  self.imageSquareUrl = [featuredEventDictionary objectForKey:@"imageSquareUrl"];
  self.imageBigUrl = [featuredEventDictionary objectForKey:@"imageBigUrl"];
  self.venueName = [eventVenue objectForKey:@"name"];
  self.priceLowest = [[featuredEventDictionary objectForKey:@"priceLowest"] floatValue];
  self.priceHighest = [[featuredEventDictionary objectForKey:@"priceHighest"] floatValue];
  
  self.lastUpdateDate = [NSDate date];

  commitDefaultMOC();
}
*/
- (void)updateWithFirstName:(NSString*)firstName
                   lastName:(NSString*)lastName
                     gender:(NSString*)gender
                      email:(NSString*)email
          heightCentimeters:(float)heightCentimeters
             heightIsMetric:(BOOL)heightIsMetric
            weightKilograms:(float)weightKilograms
             weightIsMetric:(BOOL)weightIsMetric
                  birthDate:(NSDate*)birthDate
{
  self.firstName = firstName;
  self.lastName = lastName;
  self.gender = gender;
  self.email = email;
  self.heightCentimeters = heightCentimeters;
  self.heightIsMetric = heightIsMetric;
  self.weightKilograms = weightKilograms;
  self.weightIsMetric = weightIsMetric;
  self.birthDate = birthDate;
}

/*
#pragma mark Delete methods

+ (void) cleanDataToDate:(NSDate *)toDate
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastUpdateDate < %@", toDate];
  
  deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());  
}
*/
@end
