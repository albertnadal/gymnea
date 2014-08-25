//
//  Workout.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Workout : NSManagedObject

@property (nonatomic) int32_t workoutId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) BOOL saved;
@property (nonatomic) int32_t frequency;
@property (nonatomic) int32_t typeId;
@property (nonatomic) int32_t levelId;
@property (nonatomic, retain) NSData *photoMedium;
@property (nonatomic, retain) NSData *photoSmall;

@end