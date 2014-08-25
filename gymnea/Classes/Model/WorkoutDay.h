//
//  WorkoutDay.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutDetail.h"


@interface WorkoutDay : NSManagedObject

@property (nonatomic) int32_t workoutDayId;
@property (nonatomic) int32_t dayNumber;
@property (nonatomic, retain) NSString * dayName;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) WorkoutDetail* workout;
@property (nonatomic, retain) NSSet * workoutDayExercises;

@end