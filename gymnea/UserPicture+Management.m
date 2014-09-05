//
//  UserPicture+Management.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 02/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "UserPicture+Management.h"
#import "ModelUtil.h"

static NSString * const kEntityName = @"UserPicture";

@implementation UserPicture (Management)

#pragma mark Insert methods

+ (UserPicture *)userPictureWithPictureId:(int32_t)pictureId
                              photoMedium:(NSData*)photoMedium
                                 photoBig:(NSData*)photoBig
                              pictureDate:(NSDate*)pictureDate

{
    UserPicture *newUserPicture = (UserPicture *) [NSEntityDescription insertNewObjectForEntityForName:kEntityName inManagedObjectContext:defaultManagedObjectContext()];

    [newUserPicture updateWithPictureId:pictureId
                            photoMedium:photoMedium
                               photoBig:photoBig
                            pictureDate:pictureDate];

    if(!pictureId) {
        newUserPicture.temporalPictureId = 1000 + (arc4random() % 10000000);
    }

    commitDefaultMOC();
    return newUserPicture;
}

- (void)updateWithDictionary:(NSDictionary *)pictureDict
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[pictureDict objectForKey:@"day"] intValue]];
    [components setMonth:[[pictureDict objectForKey:@"month"] intValue]];
    [components setYear:[[pictureDict objectForKey:@"year"] intValue]];

    [self updateWithPictureId:[[pictureDict objectForKey:@"id"] intValue]
                            photoMedium:[pictureDict objectForKey:@"photoMedium"]
                               photoBig:[pictureDict objectForKey:@"photoBig"]
                            pictureDate:[calendar dateFromComponents:components]];

    commitDefaultMOC();
}

- (void)updateModelInDB
{
    commitDefaultMOC();
}

+ (UserPicture*)updateUserPictureWithId:(int)pictureId
                         withDictionary:(NSDictionary *)pictureDict
{
    UserPicture *userPicture = [UserPicture getUserPictureInfo:pictureId];

    if(userPicture != nil) {

        // Update register
        [userPicture updateWithDictionary:pictureDict];

    } else {

        // Insert register
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[[pictureDict objectForKey:@"day"] intValue]];
        [components setMonth:[[pictureDict objectForKey:@"month"] intValue]];
        [components setYear:[[pictureDict objectForKey:@"year"] intValue]];

        userPicture = [UserPicture userPictureWithPictureId:[[pictureDict objectForKey:@"id"] intValue]
                                                photoMedium:[pictureDict objectForKey:@"photoMedium"]
                                                   photoBig:[pictureDict objectForKey:@"photoBig"]
                                                pictureDate:[calendar dateFromComponents:components]];
    }

    return userPicture;
}

+ (UserPicture*)updateUserPictureImageWithId:(int)pictureId
                                    withSize:(GymneaUserPictureImageSize)size
                                   withImage:(UIImage *)image
{
    UserPicture *userPicture = [UserPicture getUserPictureInfo:pictureId];

    if(userPicture != nil) {
        // Update register
        if(size == UserPictureImageSizeMedium) {
            [userPicture setPhotoMedium:UIImagePNGRepresentation(image)];
        } else if(size == UserPictureImageSizeBig) {
            [userPicture setPhotoBig:UIImagePNGRepresentation(image)];
        }

        commitDefaultMOC();
    }

    return userPicture;
}

#pragma mark Select methods

+ (UserPicture*)getUserPictureInfo:(int)pictureId
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pictureId == %d", pictureId];

  UserPicture *userPictureInfo = (UserPicture*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());

  return userPictureInfo;
}

+ (UserPicture*)getUserPictureInfoWithTemporalPictureId:(int)tempPictureId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"temporalPictureId == %d", tempPictureId];
    
    UserPicture *userPictureInfo = (UserPicture*) fetchManagedObject(kEntityName, predicate, nil, defaultManagedObjectContext());
    
    return userPictureInfo;
}

- (void)updateWithPhotoMedium:(NSData *)photoMedium
{
    self.photoMedium = photoMedium;

    commitDefaultMOC();
}

- (void)updateWithPhotoBig:(NSData *)photoBig
{
    self.photoBig = photoBig;

    commitDefaultMOC();
}

- (void)updateWithPictureId:(int32_t)pictureId
                photoMedium:(NSData*)photoMedium
                   photoBig:(NSData*)photoBig
                pictureDate:(NSDate*)pictureDate

{
    self.pictureId = pictureId;
    self.photoMedium = photoMedium;
    self.photoBig = photoBig;
    self.pictureDate = pictureDate;
}

+ (NSArray *)getUserPictures
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pictureId >= %d", 0];

    return fetchManagedObjects(kEntityName, predicate, nil, defaultManagedObjectContext());
}

#pragma mark Delete methods

+ (void)deletePictureWithPictureId:(int)pictureId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pictureId == %d", pictureId];

    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

+ (void)deletePictureWithTemporalPictureId:(int)temporalPictureId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"temporalPictureId == %d", temporalPictureId];

    deleteManagedObjects(kEntityName, predicate, defaultManagedObjectContext());
}

@end
