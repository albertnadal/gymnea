//
//  PicturesViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 01/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "PicturesViewController.h"
#import "MWPhotoBrowser.h"
#import "MWCommon.h"
#import "GEALabel+Gymnea.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSData+Base64.h"
#import "UIImage+Resize.h"

@interface PicturesViewController ()<MWPhotoBrowserDelegate>
{
    NSMutableArray *_selections;
    UIImage *lastPhotoTaken;
}

@property (nonatomic, retain) NSMutableArray *sourcePhotos;
@property (nonatomic, retain) NSMutableArray *sourceThumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, retain) UIImage *lastPhotoTaken;

- (void)loadAssets;
- (void)uploadLastPhotoTaken;

@end

@implementation PicturesViewController

@synthesize loadingData;
@synthesize needRefreshData;
@synthesize lastPhotoTaken;

- (id)init
{
    self = [super initWithNibName:@"PicturesViewController" bundle:nil];
    if (self)
    {
        [self _initialisation];
        self.delegate = self;
        self.needRefreshData = TRUE;
        self.loadingData = FALSE;
        self.lastPhotoTaken = FALSE;

        [self loadAssets];

        return self;
    }

    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.noPicturesFoundLabel setHidden:YES];

    self.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Pictures" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)loadInitialData
{
    
    if((self.needRefreshData) && (!self.loadingData)) {
        
        self.loadingData = TRUE;

        [self.noPicturesFoundLabel setHidden:YES];
        self.loadPicturesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadPicturesHud.labelText = @"Loading pictures";
        
        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient requestUserPicturesWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *userPictures) {

            if(success == GymneaWSClientRequestSuccess) {
                self.needRefreshData = FALSE;

                [self loadPicturesFromArray:userPictures];
                [self loadVisuals];

                [[self.loadPicturesHud superview] bringSubviewToFront:self.loadPicturesHud];

                // Hide HUD after 0.3 seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.noPicturesFoundLabel setHidden:YES];
                    [self.loadPicturesHud hide:YES];
                    self.loadingData = FALSE;

                    [self viewWillAppear:YES];
                    [self reloadData];

                });

            } else {

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];

                [self.loadPicturesHud hide:YES];
                self.loadingData = FALSE;
                self.needRefreshData = TRUE;
                [self.noPicturesFoundLabel setHidden:NO];
            }

        }];

    }

}

- (void)loadPicturesFromArray:(NSArray *)picList
{
    self.sourcePhotos = [[NSMutableArray alloc] init];
    self.sourceThumbs = [[NSMutableArray alloc] init];

    MWPhoto *photo;

    for(UserPicture *userPicture in picList)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];

        photo = [MWPhoto photoWithPictureId:userPicture.pictureId withTempPictureId:userPicture.temporalPictureId withSize:UserPictureImageSizeBig];
        photo.caption = [formatter stringFromDate:[userPicture pictureDate]];
        [self.sourcePhotos addObject:photo];
        [self.sourceThumbs addObject:[MWPhoto photoWithPictureId:userPicture.pictureId withTempPictureId:userPicture.temporalPictureId withSize:UserPictureImageSizeMedium]];
    }

    // Create browser

    self.displayActionButton = YES;
    self.displayNavArrows = NO;
    self.displaySelectionButtons = NO;
    self.alwaysShowControls = NO;
    self.zoomPhotosToFill = YES;
    self.enableGrid = YES;
    self.startOnGrid = YES;
    self.enableSwipeToDismiss = YES;

    [self setCurrentPhotoIndex:0];

}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.sourcePhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.sourcePhotos.count)
        return [self.sourcePhotos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < self.sourceThumbs.count)
        return [self.sourceThumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteButtonPressedForPhotoAtIndex:(NSUInteger)index
{
    if(index >= self.sourcePhotos.count) return;

    MWPhoto *photo = (MWPhoto *)[self.sourcePhotos objectAtIndex:index];

    if(photo.pictureId) {

        self.loadingData = TRUE;
        
        [self.noPicturesFoundLabel setHidden:YES];
        self.loadPicturesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadPicturesHud.labelText = @"Removing picture";
        
        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient deleteUserPicture:photo.pictureId
                      withCompletionBlock:^(GymneaWSClientRequestStatus success) {

                          if(success == GymneaWSClientRequestSuccess) {
                              self.needRefreshData = FALSE;

                              [self.sourcePhotos removeObjectAtIndex:index];
                              [self.sourceThumbs removeObjectAtIndex:index];
                              [self loadVisuals];
                              
                              [[self.loadPicturesHud superview] bringSubviewToFront:self.loadPicturesHud];
                              
                              // Hide HUD after 0.3 seconds
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                  [self.noPicturesFoundLabel setHidden:[self.sourcePhotos count]];

                                  [self.loadPicturesHud hide:YES];
                                  self.loadingData = FALSE;
                                  self.needRefreshData = FALSE;

                                  [self reloadData];
                                  [self viewWillAppear:YES];
                                  
                              });
                              
                          } else {
                              
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                              [alert show];

                              [self.sourcePhotos removeObjectAtIndex:index];
                              [self.sourceThumbs removeObjectAtIndex:index];
                              [self loadVisuals];

                              [self.loadPicturesHud hide:YES];
                              self.loadingData = FALSE;
                              self.needRefreshData = TRUE;

                              [self.noPicturesFoundLabel setHidden:[self.sourcePhotos count]];

                              [self viewWillAppear:YES];
                              [self reloadData];
                          }

        }];

    } else if(photo.temporalPictureId) {

        [UserPicture deletePictureWithTemporalPictureId:photo.temporalPictureId];
        [self.sourcePhotos removeObjectAtIndex:index];
        [self.sourceThumbs removeObjectAtIndex:index];
        [self loadVisuals];

        self.loadingData = FALSE;
        self.needRefreshData = TRUE;
        
        [self.noPicturesFoundLabel setHidden:[self.sourcePhotos count]];

        [self viewWillAppear:YES];
        [self reloadData];
    }

}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {

}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets

- (void)loadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(_assets) {
                                               [_assets addObject:asset];
                                               if (_assets.count == 1) {
                                                   // Added first asset so reload data
                                                   // DO SOMETHING!
                                               }
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){

                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {

                                       }];
        
    });
    
}

- (void)uploadLastPhotoTaken
{
     UIImageWriteToSavedPhotosAlbum(self.lastPhotoTaken, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
     UIImage *fixedRotationImage = [self fixrotation:self.lastPhotoTaken];
     CGFloat originalWidth = fixedRotationImage.size.width;
     CGFloat originalHeight = fixedRotationImage.size.height;
     
     CGFloat imageHeight = 774.0f;
     CGFloat imageWidth = (originalWidth * 774.0f) / originalHeight;
     
     UIImage *image = [fixedRotationImage resizedImageToFitInSize:CGSizeMake(imageWidth, imageHeight) scaleIfSmaller:YES];
     
     UIImage *imageCropped = [self imageByCropping:image toRect:CGRectMake(0, (imageHeight/2.0f) - (imageWidth/2.0f), imageWidth, imageWidth)];
    
     UIImage *imageMediumCropped = [imageCropped resizedImageToFitInSize:CGSizeMake(275, 275) scaleIfSmaller:YES];

    UserPicture *userPicture = [UserPicture userPictureWithPictureId:0
                                                         photoMedium:UIImagePNGRepresentation(imageMediumCropped)
                                                            photoBig:UIImagePNGRepresentation(imageCropped)
                                                         pictureDate:[NSDate date]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    [[GymneaWSClient sharedInstance] uploadUserPicture:userPicture
                                   withCompletionBlock:^(GymneaWSClientRequestStatus success, NSNumber *userPictureId) {

                                       // Add the new photo to the sourcePhotos list

                                        MWPhoto *photo = [MWPhoto photoWithPictureId:[userPictureId intValue] withTempPictureId:[userPicture temporalPictureId] withSize:UserPictureImageSizeBig withImage:imageCropped];
                                        photo.caption = [formatter stringFromDate:[userPicture pictureDate]];
                                        [self.sourcePhotos insertObject:photo atIndex:0];
                                        [self.sourceThumbs insertObject:[MWPhoto photoWithPictureId:[userPictureId intValue] withTempPictureId:[userPicture temporalPictureId] withSize:UserPictureImageSizeMedium withImage:imageMediumCropped] atIndex:0];

                                       
                                       [self deleteGridController];
                                       [self loadVisuals];
                                       [self showGrid:NO];
                                       
                                       if(success == GymneaWSClientRequestSuccess) {
                                           
                                           // Hide HUD after 0.3 seconds
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                                               [self.noPicturesFoundLabel setHidden:YES];
                                               [_cameraButton setEnabled:YES];
                                               [self.loadPicturesHud hide:YES];
                                               self.loadingData = FALSE;
                                               self.needRefreshData = TRUE;
                                               
                                               [self viewWillAppear:YES];
                                               [self reloadData];
                                               
                                               // Show added picture
                                               [self setCurrentPhotoIndex:0];
                                               [self hideGrid];
                                           });
                                           
                                       } else {
                                           
                                           // Hide HUD after 0.3 seconds
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                                               [alert show];
                                               
                                               [self.loadPicturesHud hide:YES];
                                               self.loadingData = FALSE;
                                               self.needRefreshData = TRUE;
                                               [self.noPicturesFoundLabel setHidden:YES];
                                               [_cameraButton setEnabled:YES];
                                               
                                               [self viewWillAppear:YES];
                                               [self reloadData];
                                               
                                               // Show added picture
                                               [self setCurrentPhotoIndex:0];
                                               [self hideGrid];
                                               
                                           });
                                       }
                                       
                            }];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self showGrid:NO];
    self.lastPhotoTaken = info[UIImagePickerControllerOriginalImage];

    [self dismissViewControllerAnimated:YES completion:^{

        [_cameraButton setEnabled:FALSE];
        self.loadPicturesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadPicturesHud.labelText = @"Saving picture";
        self.loadingData = TRUE;

        [self performSelector:@selector(uploadLastPhotoTaken) withObject:nil afterDelay:0.3];

    }];
}

-(UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

-(UIImage *)fixrotation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
