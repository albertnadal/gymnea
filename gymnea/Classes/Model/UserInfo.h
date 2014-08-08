//
//  UserInfo.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/06/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic) float heightCentimeters;
@property (nonatomic) BOOL heightIsMetric;
@property (nonatomic) float weightKilograms;
@property (nonatomic) BOOL weightIsMetric;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSDate * birthDate;

@end
