//
//  WorkoutDetail.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 8/22/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WorkoutDetail : NSManagedObject

@property (nonatomic) int32_t workoutId;
@property (nonatomic, retain) NSString *workoutDescription;
@property (nonatomic, retain) NSString *muscles;
@property (nonatomic, retain) NSSet *workoutDays;

@end