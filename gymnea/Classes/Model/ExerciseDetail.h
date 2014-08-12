//
//  Event.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 5/27/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExerciseDetail : NSManagedObject

@property (nonatomic) int16_t ageRestriction;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic) BOOL featured;
@property (nonatomic, retain) NSString * imageBigUrl;
@property (nonatomic, retain) NSString * imageHorizontalUrl;
@property (nonatomic, retain) NSString * imageSquareUrl;
@property (nonatomic, retain) NSString * imageVerticalUrl;
//@property (nonatomic) NSTimeInterval lastUpdateDate;
@property (nonatomic, retain) NSDate *lastUpdateDate;
@property (nonatomic) float priceHighest;
@property (nonatomic) float priceLowest;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * difficulty;
@property (nonatomic, retain) NSString * muscles;
@property (nonatomic) int32_t daysAWeek;
@property (nonatomic) float rating;
@property (nonatomic, retain) NSString * venueCity;
@property (nonatomic) double venueCoordinateLatitude;
@property (nonatomic) double venueCoordinateLongitude;
@property (nonatomic, retain) NSString * venueCountry;
@property (nonatomic) int32_t venueId;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * venueState;
@property (nonatomic, retain) NSString * venueStreet;

@end