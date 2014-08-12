//
//  Exercise.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/10/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Exercise : NSManagedObject

@property (nonatomic) int32_t exerciseId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) BOOL saved;
@property (nonatomic) int32_t equipmentId;
@property (nonatomic) int32_t muscleId;
@property (nonatomic) int32_t typeId;
@property (nonatomic) int32_t levelId;
@property (nonatomic, retain) NSData *photoMedium;
@property (nonatomic, retain) NSData *photoSmall;

@end