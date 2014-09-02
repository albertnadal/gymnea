//
//  UserPicture.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 02/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserPicture : NSManagedObject

@property (nonatomic) int32_t pictureId;
@property (nonatomic, retain) NSData *photoMedium;
@property (nonatomic, retain) NSData *photoBig;
@property (nonatomic, retain) NSDate * pictureDate;

@end