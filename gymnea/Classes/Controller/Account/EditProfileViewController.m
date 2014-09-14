//
//  EditProfileViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 14/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "EditProfileViewController.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GEALabel+Gymnea.h"
#import "UIImage+Resize.h"

@interface EditProfileViewController ()

@property (nonatomic, retain) IBOutlet UILabel *viewTitle;
@property (nonatomic, retain) IBOutlet UIImageView *userAvatar;
@property (nonatomic, retain) IBOutlet UIView *userAvatarView;
@property (nonatomic, retain) UIImage *lastPhotoTaken;

- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)showChangePictureOptionsMenu:(id)sender;
- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:self.viewTitle.text fontSize:18.0f frame:self.viewTitle.frame];
    [self.view addSubview:titleModal];
    [self.viewTitle removeFromSuperview];

    // Make the user picture full rounded
    UIBezierPath *userPictureViewShadowPath = [UIBezierPath bezierPathWithRect:self.userAvatarView.bounds];
    self.userAvatarView.layer.shadowPath = userPictureViewShadowPath.CGPath;
    self.userAvatarView.layer.rasterizationScale = 2;
    self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.size.width / 2.0f;;
    self.userAvatarView.layer.masksToBounds = YES;

    self.lastPhotoTaken = nil;
}

- (IBAction)showChangePictureOptionsMenu:(id)sender
{
    UIActionSheet *popupOptions = [[UIActionSheet alloc] initWithTitle:@"Change avatar" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Take new picture", @"Choose existing picture", nil];
    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
    [popupOptions showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIView *overlayView = nil;

    switch (buttonIndex) {
        case 0:         // Take a new picture from camera
                        {
                            sourceType = UIImagePickerControllerSourceTypeCamera;

                            CGRect overlayFrame = [[UIScreen mainScreen] bounds];
                            overlayFrame.size.height-=100;
                            overlayView = [[UIView alloc] initWithFrame:overlayFrame];
                            UIView *topBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 40, [[UIScreen mainScreen] bounds].size.width, 35)];
                            [topBlack setBackgroundColor:[UIColor blackColor]];
                            [overlayView addSubview:topBlack];

                            UIView *bottomBlack = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topBlack.frame) + [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width, 103)];
                            [bottomBlack setBackgroundColor:[UIColor blackColor]];
                            [overlayView addSubview:bottomBlack];
                        }

                        break;

        case 1:         // Choose a picture from camera roll
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                        break;

        default:
                        break;
    }

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = NO;

        if(overlayView) {
            [imagePicker setCameraOverlayView: overlayView];
        }

        [self presentViewController:imagePicker animated:YES completion:nil];
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.lastPhotoTaken = [self fixrotation:info[UIImagePickerControllerOriginalImage]];

    UIImageWriteToSavedPhotosAlbum(self.lastPhotoTaken, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    UIImage *fixedRotationImage = [self fixrotation:self.lastPhotoTaken];
    CGFloat originalWidth = fixedRotationImage.size.width;
    CGFloat originalHeight = fixedRotationImage.size.height;
    
    CGFloat imageHeight = 774.0f;
    CGFloat imageWidth = (originalWidth * 774.0f) / originalHeight;
    
    self.lastPhotoTaken = [self.lastPhotoTaken resizedImageToFitInSize:CGSizeMake(imageWidth, imageHeight) scaleIfSmaller:YES];
    
    self.lastPhotoTaken = [self imageByCropping:self.lastPhotoTaken toRect:CGRectMake(0, (imageHeight/2.0f) - (imageWidth/2.0f), imageWidth, imageWidth)];

    [picker dismissViewControllerAnimated:YES completion:^{
        [self.userAvatar setImage:self.lastPhotoTaken];
    }];
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

- (IBAction)cancelEditProfile:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
