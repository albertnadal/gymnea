//
//  UserPicture+Management.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 02/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "UserPicture.h"
#import "GEADefinitions.h"
#import <UIKit/UIKit.h>

typedef enum _GymneaUserPictureImageSize
{
    UserPictureImageSizeSmall = 0,
    UserPictureImageSizeMedium = 1,
    UserPictureImageSizeBig = 2
} GymneaUserPictureImageSize;

@interface UserPicture (Management)

+ (UserPicture *)userPictureWithPictureId:(int32_t)pictureId
                              photoMedium:(NSData*)photoMedium
                                 photoBig:(NSData*)photoBig
                              pictureDate:(NSDate*)pictureDate;

- (void)updateWithPictureId:(int32_t)pictureId
                photoMedium:(NSData*)photoMedium
                   photoBig:(NSData*)photoBig
                pictureDate:(NSDate*)pictureDate;

- (void)updateWithPhotoMedium:(NSData *)photoMedium;

- (void)updateWithPhotoBig:(NSData *)photoBig;

- (void)updateModelInDB;

- (void)updateWithDictionary:(NSDictionary *)pictureDict;

+ (UserPicture*)updateUserPictureWithId:(int)pictureId withDictionary:(NSDictionary*)pictureDict;

+ (UserPicture*)updateUserPictureImageWithId:(int)pictureId
                                    withSize:(GymneaUserPictureImageSize)size
                                   withImage:(UIImage *)image;

+ (UserPicture*)getUserPictureInfo:(int)pictureId;

+ (UserPicture*)getUserPictureInfoWithTemporalPictureId:(int)tempPictureId;

+ (NSArray *)getUserPictures;

+ (void)deletePictureWithPictureId:(int)pictureId;

+ (void)deletePictureWithTemporalPictureId:(int)temporalPictureId;

@end
