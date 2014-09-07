//
//  ExerciseDetailViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 04/08/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExerciseDetailViewController.h"
#import "GEADefinitions.h"
#import "GEAPopoverViewController.h"
#import "ExerciseDescriptionViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "GymneaWSClient.h"
#import "ExerciseDetail.h"
#import "GEALabel+Gymnea.h"
#import "UIImageView+AFNetworking.h"
#import "URBMediaFocusViewController.h"
#import "ExercisePlayViewController.h"

static float const kGEASpaceBetweenLabels = 15.0f;
static float const kGEAContainerPadding = 7.0f;
static float const kGEAHorizontalMargin = 11.0f;
static float const kGEADescriptionButtonMargin = 10.0f;

// Banner setup
static CGFloat const kGEABannerZoomFactor = 0.65f;
static CGFloat const kGEABannerOffsetFactor = 0.45f;
static float const kGEABannerTransitionCrossDissolveDuration = 0.3f;
static NSString *const kGEAEventDetailImagePlaceholder = @"workout-banner-placeholder";

@interface ExerciseDetailViewController () <ExercisePlayViewControllerDelegate, URBMediaFocusViewControllerDelegate, GEAPopoverViewControllerDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
{
    Exercise *exercise;
    ExerciseDetail *exerciseDetail;

    // Popover
    GEAPopoverViewController *popover;

    // Exercise tag photo index
    NSArray *exercisePhotoGender;
    NSArray *exercisePhotoOrder;
    int photoIndex;

    BOOL showPlayButton;
}

@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) ExerciseDetail *exerciseDetail;

@property (atomic) int exerciseId;
@property (nonatomic, weak) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) IBOutlet UIView *detailsView;
@property (nonatomic, weak) IBOutlet UIView *bannerContainer;
@property (nonatomic, weak) IBOutlet UIView *basicInfoContainer;
@property (nonatomic, strong) IBOutlet UIView *dealContainer;
@property (nonatomic, weak) IBOutlet UIView *segmentContainer;
@property (nonatomic, weak) IBOutlet UIView *buyContainer;
@property (nonatomic, weak) IBOutlet UIImageView *banner;
@property (nonatomic, weak) IBOutlet UIImageView *bannerTopShadow;
@property (nonatomic, weak) IBOutlet UIImageView *bannerBottomShadow;
@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UIButton *descriptionButton;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UILabel *exerciseType;
@property (nonatomic, weak) IBOutlet UILabel *exerciseMuscle;
@property (nonatomic, weak) IBOutlet UILabel *exerciseEquipment;
@property (nonatomic, weak) IBOutlet UILabel *exerciseLevel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseBodyZone;
@property (nonatomic, weak) IBOutlet UILabel *exerciseForce;
@property (nonatomic, weak) IBOutlet UILabel *exerciseIsSport;
@property (nonatomic, strong) GEAPopoverViewController *popover;
@property (nonatomic, weak) IBOutlet UIButton *photo1;
@property (nonatomic, weak) IBOutlet UIButton *photo2;
@property (nonatomic, weak) IBOutlet UIButton *photo3;
@property (nonatomic, weak) IBOutlet UIButton *photo4;
@property (nonatomic, strong) URBMediaFocusViewController *mediaFocusController;
@property (nonatomic, weak) IBOutlet UIButton *playExerciseButton;
@property (nonatomic, retain) MBProgressHUD *loadExerciseHud;

- (void)loadExerciseDetailData;
- (void)loadBanner;
- (void)loadNextExercisePicture;
- (void)loadExercisePictureWithGender:(GymneaExerciseImageGender)gender withOrder:(GymneaExerciseImageOrder)order;
- (void)updateEventDetailData;
- (void)updateBannerData;
- (void)updateBasicInfoData;
- (void)updateDealData;
- (void)updateSegmentControl;
- (void)updateDetailsData;
- (void)updateScroll;
- (IBAction)showDescription:(id)sender;
- (IBAction)playExercise:(id)sender;
- (void)addActionsButton;
- (void)stretchBannerWithVerticalOffset:(CGFloat)offset;
- (void)updateBannerSizeAndPosition:(CGFloat)offset;
- (void)moveBannerWithVerticalOffset:(CGFloat)offset;
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (IBAction)showExerciseImage:(id)sender;
- (void)downloadExercise;

@end

@implementation ExerciseDetailViewController

@synthesize exercise, exerciseDetail, exerciseId, popover, detailsView;

- (id)initWithExercise:(Exercise *)exercise_ showPlayButton:(BOOL)show
{
    if(self = [super initWithNibName:@"ExerciseDetailViewController" bundle:nil])
    {
        self.exercise = exercise_;
        self.exerciseDetail = nil;
        popover = nil;
        photoIndex = 0;
        exercisePhotoGender = @[ [NSNumber numberWithInteger:ExerciseImageMale], [NSNumber numberWithInteger:ExerciseImageMale], [NSNumber numberWithInteger:ExerciseImageFemale], [NSNumber numberWithInteger:ExerciseImageFemale] ];
        exercisePhotoOrder = @[ [NSNumber numberWithInteger:ExerciseImageFirst], [NSNumber numberWithInteger:ExerciseImageSecond], [NSNumber numberWithInteger:ExerciseImageFirst], [NSNumber numberWithInteger:ExerciseImageSecond] ];
        showPlayButton = show;
    }

    return self;
}

- (void)loadExerciseDetailData
{

    [[GymneaWSClient sharedInstance] requestExerciseDetailWithExercise:self.exercise withCompletionBlock:^(GymneaWSClientRequestStatus success, ExerciseDetail *theExercise) {
        if(success == GymneaWSClientRequestSuccess)
        {
            self.exerciseDetail = theExercise;

            [self loadBanner];
            [self updateEventDetailData];       // Updates the UI from model

            [self.scroll setHidden:NO];
            if(showPlayButton) {
                [self.buyContainer setHidden:NO];
            }

            [self addActionsButton];
            [self loadNextExercisePicture];

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to reach the network when retrieving the exercise information."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert setTag:1];
            [alert show];
        }

        // Hide HUD after 0.3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

            [self.loadExerciseHud hide:YES];
        });

    }];

}

- (void)downloadExercise
{
    //Just download the video loop of the exercise is needed to complete all the missing exercise attributes

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Downloading exercise";

    [[GymneaWSClient sharedInstance] requestExerciseVideoLoopWithExercise:self.exercise
                                                      withCompletionBlock:^(GymneaWSClientRequestStatus success, NSData *video) {

                                                          if((success == GymneaWSClientRequestSuccess) && (video != nil)) {
                                                              self.exerciseDetail.videoLoop = video;
                                                              [self.playExerciseButton setTitle:@"Play Exercise" forState:UIControlStateNormal];

                                                          } else {
                                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                              message:@"Unable to reach the network when retrieving the exercise information."
                                                                                                             delegate:nil
                                                                                                    cancelButtonTitle:@"Ok"
                                                                                                    otherButtonTitles:nil];
                                                              [alert setTag:1];
                                                              [alert show];

                                                          }

                                                          // Hide HUD after 0.3 seconds
                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                                                              [hud hide:YES];
                                                          });

                                                      }];

}

- (void)exerciseFinished:(ExercisePlayViewController *)exercisePlay
{
    [self.navigationController popToViewController:self animated:NO];
    self.navigationController.navigationBar.hidden = FALSE;
}

- (void)userDidSelectFinishExercise:(ExercisePlayViewController *)exercisePlay
{
    [self.navigationController popToViewController:self animated:NO];
    self.navigationController.navigationBar.hidden = FALSE;
}

- (IBAction)playExercise:(id)sender
{

    if(self.exerciseDetail.videoLoop == nil) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download is needed"
                                                        message:@"First of all is necessary to download the exercise to your device. This will let you to play this exercise anywhere without access to Internet."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Download", nil];

        [alert setTag:2];
        [alert show];

    } else {

        ExercisePlayViewController *epvc = [[ExercisePlayViewController alloc] initWithExercise:self.exercise withDetails:self.exerciseDetail withDelegate:self];
        [self.navigationController pushViewController:epvc animated:NO];

    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 2)
    {
        if(buttonIndex == 1)
        {
            // Download exercise
            [self downloadExercise];
        }
    }
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

- (void)loadBanner
{

    [[GymneaWSClient sharedInstance] requestImageForExercise:exercise.exerciseId
                                                    withSize:ExerciseImageSizeMedium
                                                  withGender:ExerciseImageMale
                                                   withOrder:ExerciseImageFirst
                                         withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {

                                             if(image == nil) {
                                                 image = [UIImage imageNamed:@"exercise-default-thumbnail"];
                                             }

                                             UIImage *imageCropped = [self imageByCropping:image toRect:CGRectMake(0, (image.size.height/2.0f) - (120.0f/2.0f), image.size.width, 120.0f)];

                                             if(success==GymneaWSClientRequestSuccess) {
                                                 // First of all is necessary to rescale the image if the image width is diferent from the device screen width.
                                                 if(imageCropped.size.width != [[UIScreen mainScreen] bounds].size.width)
                                                 {

                                                     CGFloat bannerWidth = [[UIScreen mainScreen] bounds].size.width;
                                                     CGFloat bannerHeight = floor((([[UIScreen mainScreen] bounds].size.width * imageCropped.size.height) / imageCropped.size.width) + 0.5f);
                                                     CGSize newBannerSize = CGSizeMake(bannerWidth, bannerHeight);

                                                     UIGraphicsBeginImageContext(newBannerSize);
                                                     [imageCropped drawInRect:CGRectMake(0, 0, newBannerSize.width, newBannerSize.height)];

                                                     // Cross dissolve effect
                                                     [UIView transitionWithView:self.view
                                                                       duration:kGEABannerTransitionCrossDissolveDuration
                                                                        options:UIViewAnimationOptionTransitionCrossDissolve
                                                                     animations:^{
                                                                         [self.banner setImage:UIGraphicsGetImageFromCurrentImageContext()];
                                                                     } completion:nil];

                                                     UIGraphicsEndImageContext();
                                                 }
                                                 else
                                                 {
                                                     [self.banner setImage:imageCropped];
                                                 }

                                                 [self updateBannerData];
                                                 [self updateEventDetailData];       // Updates the UI from model

                                             }

                                         }];

        [self updateBannerData];

}

- (void)loadNextExercisePicture
{
    if(photoIndex >= [exercisePhotoGender count]) {
        return;
    }

    GymneaExerciseImageGender imageGender = (GymneaExerciseImageGender)[(NSNumber *)[exercisePhotoGender objectAtIndex:photoIndex] intValue];
    GymneaExerciseImageOrder imageOrder = (GymneaExerciseImageOrder)[(NSNumber *)[exercisePhotoOrder objectAtIndex:photoIndex] intValue];

    [self loadExercisePictureWithGender:imageGender withOrder:imageOrder];
}

- (void)loadExercisePictureWithGender:(GymneaExerciseImageGender)gender withOrder:(GymneaExerciseImageOrder)order
{

    [[GymneaWSClient sharedInstance] requestImageForExercise:exercise.exerciseId
                                                    withSize:ExerciseImageSizeMedium
                                                  withGender:gender
                                                   withOrder:order
                                         withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {

                                             if((success == GymneaWSClientRequestSuccess) && (image != nil)) {

                                                 UIButton *photoButton = nil;

                                                 if([self.photo1 backgroundImageForState:UIControlStateNormal] == nil) {
                                                     photoButton = self.photo1;

                                                 } else if([self.photo2 backgroundImageForState:UIControlStateNormal] == nil) {
                                                     photoButton = self.photo2;

                                                 } else if([self.photo3 backgroundImageForState:UIControlStateNormal] == nil) {
                                                     photoButton = self.photo3;

                                                 } else if([self.photo4 backgroundImageForState:UIControlStateNormal] == nil) {
                                                     photoButton = self.photo4;

                                                 }

                                                 if(photoButton != nil) {
                                                     [photoButton setBackgroundImage:image forState:UIControlStateNormal];
                                                     [photoButton setHidden:NO];

                                                     photoButton.layer.cornerRadius = 2.0;
                                                     UIBezierPath *photoButtonViewShadowPath = [UIBezierPath bezierPathWithRect:photoButton.bounds];
                                                     photoButton.layer.shadowPath = photoButtonViewShadowPath.CGPath;
                                                 }
                                             }

                                             photoIndex++;
                                             [self loadNextExercisePicture];
                                         }];

}

- (void)updateBasicInfoData
{
    if(self.exerciseDetail.videoLoop == nil) {
        [self.playExerciseButton setTitle:@"Play Exercise (need download)" forState:UIControlStateNormal];
    }

    CGRect bannerContainerFrame = self.bannerContainer.frame;
    CGFloat baseYPosition = bannerContainerFrame.origin.y + bannerContainerFrame.size.height + 1.0f;

    [self.eventTitle setText:self.exercise.name];
    [self.eventTitle sizeToFit];

    CGRect eventTitleFrame = self.eventTitle.frame;
    CGFloat y = eventTitleFrame.origin.y + eventTitleFrame.size.height + kGEASpaceBetweenLabels + kGEAContainerPadding;

    CGRect descriptionButtonFrame = self.descriptionButton.frame;
    descriptionButtonFrame.origin.y = y;
    [self.descriptionButton setFrame:descriptionButtonFrame];

    CGRect descriptionFrame = self.description.frame;
    descriptionFrame.origin.y = descriptionButtonFrame.origin.y + kGEADescriptionButtonMargin;
    [self.description setFrame:descriptionFrame];

    [self.description setText:[self.exerciseDetail exerciseDescription]];

    CGRect basicInfoContainerFrame = self.basicInfoContainer.frame;
    basicInfoContainerFrame.origin.y = baseYPosition;
    basicInfoContainerFrame.size.height = descriptionButtonFrame.origin.y + descriptionButtonFrame.size.height;
    [self.basicInfoContainer setFrame:basicInfoContainerFrame];
}

- (void)updateDealData
{
    CGRect basicInfoContainerFrame = self.basicInfoContainer.frame;
    CGFloat baseYPosition = CGRectGetMaxY(basicInfoContainerFrame) + kGEASpaceBetweenLabels;

    CGRect dealContainerFrame = self.dealContainer.frame;
    dealContainerFrame.origin.y = baseYPosition;
    dealContainerFrame.origin.x = kGEAHorizontalMargin;
    dealContainerFrame.size.height = 0.0f; //150.0f;
    [self.dealContainer setFrame:dealContainerFrame];

    [self.dealContainer setClipsToBounds:NO];
    [self.dealContainer.layer setMasksToBounds:NO];
    self.dealContainer.layer.shouldRasterize = YES;
    self.dealContainer.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.dealContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.dealContainer.layer.shadowOffset = CGSizeMake(0,0.8);
    self.dealContainer.layer.shadowRadius = 2;
    self.dealContainer.layer.shadowOpacity = 0.6;
    UIBezierPath *dealContainerShadowPath = [UIBezierPath bezierPathWithRect:self.dealContainer.bounds];
    self.dealContainer.layer.shadowPath = dealContainerShadowPath.CGPath;

    // The deal view is not inside the scroll in the Xib
    [self.dealContainer setHidden:YES];
    [self.scroll addSubview:self.dealContainer];
}

- (void)updateSegmentControl
{
    CGRect dealContainerFrame = self.dealContainer.frame;
    CGFloat baseYPosition = CGRectGetMaxY(dealContainerFrame);
    CGRect segmentContainerFrame = self.segmentContainer.frame;
    segmentContainerFrame.origin.y = baseYPosition;
    [self.segmentContainer setFrame:segmentContainerFrame];
}

- (void)updateDetailsData
{
    CGRect segmentContainerFrame = self.segmentContainer.frame;
    CGFloat baseYPosition = segmentContainerFrame.origin.y + segmentContainerFrame.size.height + 1.0f;

    [self.exerciseType setText:[GEADefinitions retrieveTitleForExerciseType:[self.exercise typeId]]];
    [self.exerciseMuscle setText:[GEADefinitions retrieveTitleForMuscle:[self.exercise muscleId]]];
    [self.exerciseEquipment setText:[GEADefinitions retrieveTitleForEquipment:[self.exercise equipmentId]]];
    [self.exerciseLevel setText:[GEADefinitions retrieveTitleForExerciseLevel:[self.exercise levelId]]];
    [self.exerciseBodyZone setText:[[self.exerciseDetail bodyZone] capitalizedString]];
    [self.exerciseForce setText:[[self.exerciseDetail force] capitalizedString]];
    [self.exerciseIsSport setText:[[self.exerciseDetail isSport] capitalizedString]];

    CGRect detailsViewFrame = self.detailsView.frame;
    detailsViewFrame.origin.y = baseYPosition;
    detailsViewFrame.size.height = CGRectGetMaxY(self.exerciseIsSport.frame) + kGEASpaceBetweenLabels;
    [self.detailsView setFrame:detailsViewFrame];
    [self.scroll addSubview:self.detailsView];
}

- (void)updateScroll
{
    CGFloat heightSegmentSelectedOption = self.detailsView.frame.size.height;
    CGFloat scrollContentLength = self.bannerContainer.frame.size.height + self.basicInfoContainer.frame.size.height + kGEASpaceBetweenLabels + self.dealContainer.frame.size.height + self.segmentContainer.frame.size.height + heightSegmentSelectedOption + kGEASpaceBetweenLabels;

    [self.scroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollContentLength)];
    if(!showPlayButton) {
        [self.scroll setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44.0f - 20.0f)];
    }
}

- (void)updateBannerData
{
    if(!self.banner.image)
    {
        // If not banner image is available
        [self.bannerContainer setHidden:YES];
        CGRect bannerContainerFrame = self.bannerContainer.frame;
        bannerContainerFrame.size.height = 0;
        [self.bannerContainer setFrame:bannerContainerFrame];
    }
    else
    {
        // If banner image is available to show
        [self.bannerContainer setHidden:NO];

        // Adjust banner height
        int bannerHeight = self.banner.image.size.height;
        CGRect bannerFrame = self.banner.frame;
        bannerFrame.size.height = bannerHeight;
        [self.banner setFrame:bannerFrame];

        // Adjust banner shadow position
        CGRect bannerBottomShadowFrame = self.bannerBottomShadow.frame;
        bannerBottomShadowFrame.origin.y = bannerHeight - bannerBottomShadowFrame.size.height + 1.0f;
        [self.bannerBottomShadow setFrame:bannerBottomShadowFrame];

        // Adjust banner container height
        CGRect bannerContainerFrame = self.bannerContainer.frame;
        bannerContainerFrame.size.height = bannerHeight;
        [self.bannerContainer setFrame:bannerContainerFrame];
    }
}

- (void)updateEventDetailData
{
    [self updateBannerData];
    [self updateBasicInfoData];
    [self updateDealData];
    [self updateSegmentControl];
    [self updateDetailsData];
    [self updateScroll];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingNone;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44.0f - 20.0f)];
    NSLog(@"Y: %f H: %f", self.view.frame.origin.y, self.view.frame.size.height);

    self.navigationItem.titleView = [[GEALabel alloc] initWithText:[self.exercise name] fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    self.loadExerciseHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadExerciseHud.labelText = @"Loading exercise";

    self.descriptionButton.layer.borderWidth = 1.0f;
    self.descriptionButton.layer.borderColor = [UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
    self.descriptionButton.layer.cornerRadius = 2.0;
    UIBezierPath *descriptionBackgroundViewShadowPath = [UIBezierPath bezierPathWithRect:self.descriptionButton.bounds];
    self.descriptionButton.layer.shadowPath = descriptionBackgroundViewShadowPath.CGPath;

    [self.scroll setHidden:YES];
    [self.buyContainer setHidden:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadExerciseDetailData];
    });

    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
    self.mediaFocusController.delegate = self;
    self.mediaFocusController.shouldDismissOnImageTap = YES;
}

- (IBAction)showExerciseImage:(id)sender
{
    if([sender isKindOfClass:[UIButton class]])
    {
        [self.mediaFocusController showImage:[(UIButton *)sender backgroundImageForState:UIControlStateNormal] fromView:self.view];
    }
}

- (void)addActionsButton
{
    UIBarButtonItem *navBarShareButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showPopover:)];

    [self.navigationItem setRightBarButtonItem:navBarShareButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    detailsView = nil;
    popover = nil;
}

- (IBAction)showDescription:(id)sender
{
    ExerciseDescriptionViewController *edvc = [[ExerciseDescriptionViewController alloc] initWithName:self.exercise.name withDescription:self.exerciseDetail.exerciseDescription];
    [self.navigationController pushViewController:edvc animated:YES];
}

/*
- (IBAction)buyNow:(id)sender
{
#warning the following event detail fake is used only for testing purposes. This must use the event detail information provided by the web service
    EventDetail *eventDetailTest = [[EventDetail alloc] init];
    [eventDetailTest setEventId:1];
    [eventDetailTest setBannerUrl:@"http://www.lafruitera.com/img_banner_fake.png"];
    [eventDetailTest setEventUrl:@"http://www.albertnadal.cat"];
    [eventDetailTest setTitle:@"Luces de Bohemia de Ramon del Valle-Inclán. Luces de Bohemia de Ramon del Valle-Inclán. Luces de Bohemia de Ramon del Valle-Inclán."];
    [eventDetailTest setCompany:@"Gerry McCambridge"];
    [eventDetailTest setRating:8];
    [eventDetailTest setDescription:@"Gerry McCambridge has one of the most unique acts in Las Vegas as well as one of the most unique job titles: Mentalist.\n\nAs a mentalist, Gerry reads the minds of random audience members and predicts the outcome of random situations during the performance.\nThe entire show is also laced with comedy and plenty of audience interaction, making each performance a different experience.\n\nAccess Hollywood calls it “Amazing!”. Nominated “Best Magician in Las Vegas” and voted “World’s Best Entertainer” in his field, Gerry thrills audiences with his ability to get inside the minds of others. You won’t believe it until you see him LIVE!"];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:4];
    [comps setYear:2013];
    [eventDetailTest setStartDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];

    [comps setDay:1];
    [comps setMonth:6];
    [comps setYear:2013];
    [eventDetailTest setEndDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];

    [eventDetailTest setMinPrice:35];
    [eventDetailTest setMaxPrice:120];
    [eventDetailTest setMinimalAge:18];
    [eventDetailTest setAddress:@"Variety Theater\n3667 Las Vegas Blvd South\nLas Vegas, NV 89109\nUnited States"];
    [eventDetailTest setLatitude:41.403571f];
    [eventDetailTest setLongitude:2.174472f];

    [eventDetailTest setTimes:@[@"5:00 PM", @"7:00 PM", @"9:00 PM", @"11:00 PM"]];

//    PurchaseDateAndTimesViewController *pdtvc = [[PurchaseDateAndTimesViewController alloc] initWithEvent:eventDetailTest];
//    [self.navigationController pushViewController:pdtvc animated:YES];

}*/

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }

    return params;
}

- (void)showPopover:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    if(!self.popover)
    {
        // Create an instance of GEAPopoverViewController
        self.popover = [[GEAPopoverViewController alloc] initWithDelegate:self withBarButton:button alignedTo:GEAPopoverAlignmentRight];
    }
    
    if([self.popover isPresented])
    {
        // Dismiss the popover
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        // Present the popover
        [self.popover presentPopoverInView:self.navigationController.view animated:YES];
    }
}

- (void)stretchBannerWithVerticalOffset:(CGFloat)offset
{
    if(offset>=0)
        return;
    
    CGFloat offsetAmplified = fabsf(offset*(1+kGEABannerZoomFactor));
    CGFloat offsetAmplifiedDiff = fabsf(offset*kGEABannerZoomFactor);
    
    CGRect bannerFrame = self.banner.frame;
    bannerFrame.size.height = self.banner.image.size.height + (offsetAmplified) + 0.5f;
    bannerFrame.size.width = (bannerFrame.size.height * [[UIScreen mainScreen] bounds].size.width) / self.banner.image.size.height;
    bannerFrame.origin.y = -offsetAmplified + (offsetAmplifiedDiff/2.0f);
    bannerFrame.origin.x = ([[UIScreen mainScreen] bounds].size.width - bannerFrame.size.width) / 2.0f;
    [self.banner setFrame:CGRectIntegral(bannerFrame)];

}

- (void)moveBannerWithVerticalOffset:(CGFloat)offset
{
    if(offset<0)
        return;
    
    CGRect bannerFrame = self.banner.frame;
    CGFloat y = ((offset * kGEABannerOffsetFactor));
    //bannerFrame.origin.x = 0.0f;
    bannerFrame.origin.y = y;
    
    [self.banner setFrame:bannerFrame];
}

- (void)updateBannerSizeAndPosition:(CGFloat)offset
{
    if(offset>=0)
    {
        [self moveBannerWithVerticalOffset:offset];
    }
    else
    {
        [self stretchBannerWithVerticalOffset:offset];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    [self updateBannerSizeAndPosition:contentOffset.y];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.popover dismissPopoverAnimated:YES];
}

#pragma GEAPopoverViewControllerDelegate

- (NSInteger)numberOfRowsInPopoverViewController:(GEAPopoverViewController *)popover
{
    return 2;
}

- (UIImage *)iconImageInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch (index)
    {
        case 0: return [UIImage imageNamed:@"popover-add-to-favorites"];
            break;
            
        case 1: return [UIImage imageNamed:@"popover-download"];
            break;
    }
    
    return nil;
}

- (NSString *)textInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: return @"Add to favorites";
            break;
            
        case 1: return @"Download";
            break;
    }
    
    return @"";
}

- (void)willSelectRowInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: break;

        case 1: [self downloadExercise];
                break;
    }
}

@end
