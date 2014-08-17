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

@property (nonatomic) int32_t exerciseId;
@property (nonatomic, retain) NSString *exerciseDescription;
@property (nonatomic, retain) NSString *bodyZone;
@property (nonatomic, retain) NSString *isSport;
@property (nonatomic, retain) NSString *force;
@property (nonatomic, retain) NSData *photoMaleMediumSecond;
@property (nonatomic, retain) NSData *photoMaleSmallSecond;
@property (nonatomic, retain) NSData *photoFemaleMediumFirst;
@property (nonatomic, retain) NSData *photoFemaleSmallFirst;
@property (nonatomic, retain) NSData *photoFemaleMediumSecond;
@property (nonatomic, retain) NSData *photoFemaleSmallSecond;
@property (nonatomic, retain) NSData *videoMale;
@property (nonatomic, retain) NSData *videoFemale;


@end