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
}

@property (nonatomic, retain) NSMutableArray *sourcePhotos;
@property (nonatomic, retain) NSMutableArray *sourceThumbs;
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, strong) NSMutableArray *assets;

- (void)loadAssets;

@end

@implementation PicturesViewController

@synthesize loadingData;
@synthesize needRefreshData;

- (id)init
{
    self = [super initWithNibName:@"PicturesViewController" bundle:nil];
    if (self)
    {
        [self _initialisation];
        self.delegate = self;
        self.needRefreshData = TRUE;
        self.loadingData = FALSE;

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
    
    //CGRect frameRect = CGRectMake(0,44.0f+20.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - (44.0f+20.0f));
    //self.view.frame = frameRect;
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
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

        photo = [MWPhoto photoWithPictureId:userPicture.pictureId withSize:UserPictureImageSizeBig];
        photo.caption = [formatter stringFromDate:[userPicture pictureDate]];
        [self.sourcePhotos addObject:photo];
        [self.sourceThumbs addObject:[MWPhoto photoWithPictureId:userPicture.pictureId withSize:UserPictureImageSizeMedium]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteButtonPressedForPhotoAtIndex:(NSUInteger)index
{
    NSLog(@"DELETE");
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {

}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
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
                                      NSLog(@"operation was not successfull!");
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
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];

    [self showGrid:NO];
    [self dismissViewControllerAnimated:YES completion:nil];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);

        UIImage *image = [self fixrotation:originalImage];
        CGFloat originalWidth = image.size.width;
        CGFloat originalHeight = image.size.height;

        CGFloat imageHeight = 600.0f;
        CGFloat imageWidth = (originalWidth * 600.0f) / originalHeight;

        image = [image resizedImageToFitInSize:CGSizeMake(imageWidth, imageHeight) scaleIfSmaller:YES];

        NSLog(@"W: %f | H: %f", imageWidth, imageHeight);

        UIImage *imageCropped = [self imageByCropping:image toRect:CGRectMake(0, (imageHeight/2.0f) - (imageWidth/2.0f), imageWidth, imageWidth)];

        [_cameraButton setEnabled:FALSE];
        self.loadPicturesHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadPicturesHud.labelText = @"Saving picture";

        NSData *imageData = UIImagePNGRepresentation(imageCropped);

        UIImage *imageMediumCropped = [imageCropped resizedImageToFitInSize:CGSizeMake(275, 275) scaleIfSmaller:YES];
        NSData *imageMediumData = UIImagePNGRepresentation(imageMediumCropped);

        UserPicture *userPicture = [UserPicture userPictureWithPictureId:0
                                                             photoMedium:imageMediumData
                                                                photoBig:imageData
                                                             pictureDate:[NSDate date]];

        self.loadingData = TRUE;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];

        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient uploadUserPicture:userPicture
                      withCompletionBlock:^(GymneaWSClientRequestStatus success, NSNumber *userPictureId) {

                          // Add the new photo to the sourcePhotos list
                          MWPhoto *photo = [MWPhoto photoWithPictureId:[userPictureId intValue] withSize:UserPictureImageSizeBig withImage:imageCropped];
                          photo.caption = [formatter stringFromDate:[userPicture pictureDate]];
                          [self.sourcePhotos insertObject:photo atIndex:0];
                          [self.sourceThumbs insertObject:[MWPhoto photoWithPictureId:[userPictureId intValue] withSize:UserPictureImageSizeMedium withImage:imageMediumCropped] atIndex:0];

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
