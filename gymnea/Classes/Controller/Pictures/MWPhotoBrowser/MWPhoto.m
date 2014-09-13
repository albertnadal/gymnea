//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "GymneaWSClient.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface MWPhoto () {

    BOOL _loadingInProgress;
    
}

- (void)imageLoadingComplete;

@end

@implementation MWPhoto

//@synthesize underlyingImage = _underlyingImage; // synth property from protocol
@synthesize imatge;

#pragma mark - Class Methods

+ (MWPhoto *)photoWithPictureId:(int)picId withTempPictureId:(int)tempPictureId withSize:(GymneaUserPictureImageSize)size; {
    return [[MWPhoto alloc] initWithPictureId:picId withTempPictureId:tempPictureId withSize:size];
}

+ (MWPhoto *)photoWithPictureId:(int)picId withTempPictureId:(int)tempPictureId withSize:(GymneaUserPictureImageSize)size withImage:(UIImage*)image
{
    return [[MWPhoto alloc] initWithPictureId:picId withTempPictureId:tempPictureId withSize:size withImage:image];
}

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[MWPhoto alloc] initWithImage:image];
}

// Deprecated
+ (MWPhoto *)photoWithFilePath:(NSString *)path {
    return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[MWPhoto alloc] initWithURL:url];
}

#pragma mark - Init

- (id)initWithPictureId:(int)picId withTempPictureId:(int)tempPictureId withSize:(GymneaUserPictureImageSize)size
{
    if ((self = [super init])) {
        self.pictureId = picId;
        self.pictureSize = size;
        self.temporalPictureId = tempPictureId;
    }
    return self;
}

- (id)initWithPictureId:(int)picId withTempPictureId:(int)tempPictureId withSize:(GymneaUserPictureImageSize)size withImage:(UIImage *)image
{
    if ((self = [super init])) {
        self.pictureId = picId;
        self.pictureSize = size;
        self.temporalPictureId = tempPictureId;
        _image = image;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
        self.pictureId = 0;
        self.temporalPictureId = 0;
		_image = image;
	}
	return self;
}

// Deprecated
- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
        self.pictureId = 0;
        self.temporalPictureId = 0;
		_photoURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
        self.pictureId = 0;
        self.temporalPictureId = 0;
		_photoURL = [url copy];
	}
	return self;
}

#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return self.imatge;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.imatge = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.imatge = _image;
        [self imageLoadingComplete];
        
    } else if (self.pictureId) {

            [[GymneaWSClient sharedInstance] requestImageForUserPicture:self.pictureId
                                                               withSize:self.pictureSize
                                                    withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *userPictureImage) {

                                                        if(success==GymneaWSClientRequestSuccess) {
                                                            
                                                            if(userPictureImage != nil) {

                                                                self.imatge = userPictureImage;
                                                                [self imageLoadingComplete];

                                                            }

                                                        }
                                                    }];

    } else {
        
        // Failed - no source
        @throw [NSException exceptionWithName:nil reason:nil userInfo:nil];
        
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
	//self.imatge = nil;
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
        _loadingInProgress = NO;
}

@end
