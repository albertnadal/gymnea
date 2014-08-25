//
//  WorkoutDayExercise.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 24/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutDay.h"


@interface WorkoutDayExercise : NSManagedObject

@property (nonatomic) int32_t exerciseId;
@property (nonatomic) int32_t order;
@property (nonatomic, retain) NSString * reps;
@property (nonatomic) int32_t sets;
@property (nonatomic) int32_t time;
@property (nonatomic, retain) NSString * muscle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t workoutDayId;
@property (nonatomic, retain) WorkoutDay * workoutDay;

@end