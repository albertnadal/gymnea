//
//  WorkoutDetailViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDetailViewController.h"
#import "GEAPopoverViewController.h"
#import "EventReviewViewController.h"
#import "WorkoutDescriptionViewController.h"
#import "WorkoutDayTableViewController.h"
#import "AppDelegate.h"
#import "EventReview.h"
#import <QuartzCore/QuartzCore.h>
#import "GymneaWSClient.h"
#import "Exercise.h"
#import "ExerciseDetail.h"
#import "GEALabel+Gymnea.h"
#import "UIImageView+AFNetworking.h"
#import "ChooseWorkoutDayViewController.h"
#import "WorkoutPlayViewController.h"
#import "ExerciseDetailViewController.h"
#import "MBProgressHUD.h"

#define DETAILS_SEGMENT_INDEX 0
#define WORKOUT_DAYS_SEGMENT_INDEX 1

static float const kGEASpaceBetweenLabels = 15.0f;
static float const kGEAContainerPadding = 7.0f;
static float const kGEAHorizontalMargin = 11.0f;
static float const kGEADescriptionButtonMargin = 10.0f;

// Banner setup
static CGFloat const kGEABannerZoomFactor = 0.65f;
static CGFloat const kGEABannerOffsetFactor = 0.45f;
static float const kGEABannerTransitionCrossDissolveDuration = 0.3f;
static NSString *const kGEAEventDetailImagePlaceholder = @"workout-banner-placeholder";

@interface WorkoutDetailViewController () <GEAPopoverViewControllerDelegate, UIScrollViewDelegate, ChooseWorkoutDayViewControllerDelegate, WorkoutDayTableViewControllerDelegate>
{
    Workout *workout;
    WorkoutDetail *workoutDetail;
    
    // Popover
    GEAPopoverViewController *popover;

    // Scroll and containers
    UIView *reviewsView;
    WorkoutDayTableViewController *workoutDaysTableViewController;

    // State flags
    bool showingDetails;
}

@property (atomic) int eventId;
@property (nonatomic, weak) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) IBOutlet UIView *detailsView;
@property (nonatomic, strong) UIView *reviewsView;
@property (nonatomic, strong) WorkoutDayTableViewController *workoutDaysTableViewController;
@property (nonatomic, weak) IBOutlet UIView *bannerContainer;
@property (nonatomic, weak) IBOutlet UIView *basicInfoContainer;
@property (nonatomic, strong) IBOutlet UIView *dealContainer;
@property (nonatomic, weak) IBOutlet UIView *segmentContainer;
@property (nonatomic, weak) IBOutlet UIView *buyContainer;
@property (nonatomic, weak) IBOutlet UIImageView *banner;
@property (nonatomic, weak) IBOutlet UIImageView *bannerTopShadow;
@property (nonatomic, weak) IBOutlet UIImageView *bannerBottomShadow;
@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UIImageView *ratingImage;
@property (nonatomic, weak) IBOutlet UILabel *overallRating;
@property (nonatomic, weak) IBOutlet UIView *scoreBackgroundView;
@property (nonatomic, weak) IBOutlet UIButton *descriptionButton;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UILabel *workoutType;
@property (nonatomic, weak) IBOutlet UILabel *workoutFrequency;
@property (nonatomic, weak) IBOutlet UILabel *workoutDifficulty;
@property (nonatomic, weak) IBOutlet UILabel *workoutMuscles;
@property (nonatomic, strong) GEAPopoverViewController *popover;
@property (nonatomic) bool showingDetails;
@property (nonatomic, strong) Workout *workout;
@property (nonatomic, strong) WorkoutDetail *workoutDetail;
@property (nonatomic, strong) NSArray *eventReviews;
@property (nonatomic, retain) MBProgressHUD *loadWorkoutHud;


- (void)loadWorkoutDetailData;
- (void)loadEventReviewsData;
- (void)loadBanner;
- (void)updateWorkoutDetailData;
- (void)updateBannerData;
- (void)updateBasicInfoData;
- (void)updateDealData;
- (void)updateSegmentControl;
- (void)updateDetailsData;
- (void)updateReviewsData;
- (void)updateWorkoutDaysData;
- (void)updateScroll;
- (IBAction)showSelectedSegment:(id)sender;
- (IBAction)showDescription:(id)sender;
- (IBAction)startWorkout:(id)sender;
- (void)addActionsButton;
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (void)stretchBannerWithVerticalOffset:(CGFloat)offset;
- (void)updateBannerSizeAndPosition:(CGFloat)offset;
- (void)moveBannerWithVerticalOffset:(CGFloat)offset;
- (NSString *)stringFromFloat:(float)value;

@end

@implementation WorkoutDetailViewController

@synthesize workout, workoutDetail, showingDetails, popover, eventReviews, reviewsView, detailsView, workoutDaysTableViewController;

- (id)initWithWorkout:(Workout *)workout_;
{
    if(self = [super initWithNibName:@"WorkoutDetailViewController" bundle:nil])
    {
        showingDetails = true; // Showing 'Details' (default) or 'Reviews'
        popover = nil;
        eventReviews = nil;
        reviewsView = nil;
        workoutDaysTableViewController = nil;

        self.workout = workout_;
        self.workoutDetail = nil;
        popover = nil;

    }

    return self;
}

- (void)loadWorkoutDetailData
{
    [[GymneaWSClient sharedInstance] requestWorkoutDetailWithWorkout:self.workout withCompletionBlock:^(GymneaWSClientRequestStatus success, WorkoutDetail *theWorkout) {
        if(success == GymneaWSClientRequestSuccess)
        {
            self.workoutDetail = theWorkout;
            
            [self loadBanner];
            [self updateWorkoutDetailData];
            
            [self.scroll setHidden:NO];
            [self.buyContainer setHidden:NO];
            
            [self addActionsButton];

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to reach the network when retrieving the workout information."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert setTag:1];
            [alert show];
        }
        
        // Hide HUD after 0.3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self.loadWorkoutHud hide:YES];
        });
        
    }];
}

- (IBAction)startWorkout:(id)sender
{
    ChooseWorkoutDayViewController *chooseWorkoutDayViewController = [[ChooseWorkoutDayViewController alloc] initWithDelegate:self];
    [self presentViewController:chooseWorkoutDayViewController animated:YES completion:nil];
}

- (void)loadEventReviewsData
{
    NSMutableArray *eventReviewsTemp = [[NSMutableArray alloc] init];

    EventReview *eventReview1 = [[EventReview alloc] init];
    [eventReview1 setOrder:1];
    [eventReview1 setTitle:[NSString stringWithFormat:@"%d. The best course to golf in the US", 1]];
    [eventReview1 setRating:3];
    [eventReview1 setAuthor:@"John Smith"];

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:22];
    [comps setMonth:12];
    [comps setYear:2012];
    [eventReview1 setDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
    [eventReview1 setText:@"Lorem ipsum dolor sit amet consectetur proin gravida nibh vel velit auctor aliquet, aenean!"];

    [eventReviewsTemp addObject:eventReview1];


    EventReview *eventReview2 = [[EventReview alloc] init];
    [eventReview2 setOrder:2];
    [eventReview2 setTitle:[NSString stringWithFormat:@"%d. Good but it could improve", 2]];
    [eventReview2 setRating:3];
    [eventReview2 setAuthor:@"Mark Edwards"];
    
    comps = [[NSDateComponents alloc] init];
    [comps setDay:20];
    [comps setMonth:12];
    [comps setYear:2012];
    [eventReview2 setDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
    [eventReview2 setText:@"Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor, nisi elit consequat ipsum, nec sagittis sem nibh id elit."];
    
    [eventReviewsTemp addObject:eventReview2];



    EventReview *eventReview3 = [[EventReview alloc] init];
    [eventReview3 setOrder:3];
    [eventReview3 setTitle:[NSString stringWithFormat:@"%d. Good but it could improve", 3]];
    [eventReview3 setRating:3];
    [eventReview3 setAuthor:@"Mark Edwards"];
    
    comps = [[NSDateComponents alloc] init];
    [comps setDay:20];
    [comps setMonth:12];
    [comps setYear:2012];
    [eventReview3 setDate:[[NSCalendar currentCalendar] dateFromComponents:comps]];
    [eventReview3 setText:@"Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor, nisi elit consequat ipsum, nec sagittis sem nibh id elit."];
    
    [eventReviewsTemp addObject:eventReview3];



    self.eventReviews = [NSArray arrayWithArray:eventReviewsTemp];
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
    [[GymneaWSClient sharedInstance] requestImageForWorkout:workout.workoutId
                                                   withSize:WorkoutImageSizeMedium
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
                                                [self updateWorkoutDetailData];       // Updates the UI from model

                                            }

    }];

    [self updateBannerData];

}

- (void)updateBasicInfoData
{

    CGRect bannerContainerFrame = self.bannerContainer.frame;
    CGFloat baseYPosition = bannerContainerFrame.origin.y + bannerContainerFrame.size.height + 1.0f;

    [self.eventTitle setText:self.workout.name];
    [self.eventTitle sizeToFit];

    CGRect eventTitleFrame = self.eventTitle.frame;
    CGFloat y = eventTitleFrame.origin.y + eventTitleFrame.size.height + kGEASpaceBetweenLabels + kGEAContainerPadding;

    CGRect ratingImageFrame = self.ratingImage.frame;
    ratingImageFrame.origin.y = y;
    [self.ratingImage setFrame:ratingImageFrame];

    CGRect overallRatingFrame = self.overallRating.frame;
    overallRatingFrame.origin.y = y;
    [self.overallRating setFrame:overallRatingFrame];

    CGRect scoreBackgroundViewFrame = self.scoreBackgroundView.frame;
    scoreBackgroundViewFrame.origin.y = ratingImageFrame.origin.y - kGEAContainerPadding - 1.0f;
    [self.scoreBackgroundView setFrame:scoreBackgroundViewFrame];

    // Round the corners of the score background
    self.scoreBackgroundView.layer.cornerRadius = 2.0;
    UIBezierPath *scoreBackgroundViewShadowPath = [UIBezierPath bezierPathWithRect:self.scoreBackgroundView.bounds];
    self.scoreBackgroundView.layer.shadowPath = scoreBackgroundViewShadowPath.CGPath;

    y = ratingImageFrame.origin.y + ratingImageFrame.size.height + kGEASpaceBetweenLabels + kGEAContainerPadding;

    CGRect descriptionButtonFrame = self.descriptionButton.frame;
    descriptionButtonFrame.origin.y = y;
    [self.descriptionButton setFrame:descriptionButtonFrame];

    CGRect descriptionFrame = self.description.frame;
    descriptionFrame.origin.y = descriptionButtonFrame.origin.y + kGEADescriptionButtonMargin;
    [self.description setFrame:descriptionFrame];

    [self.description setText:self.workoutDetail.workoutDescription];

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

- (NSString *)stringFromFloat:(float)value
{
/*
    bool valueHasDecimals = (value - (int)value > 0.0f);
    NSString *valueString;

    if(valueHasDecimals)
    {
        // This value has decimals.
        valueString = [NSString stringWithFormat:@"%.2f", self.eventDetail.priceLowest];
    }
    else
    {
        // This value does not has decimals.
        valueString = [NSString stringWithFormat:@"%d", (int)self.eventDetail.priceLowest];
    }

    return valueString;
*/
    return nil;
}

- (void)updateWorkoutDaysData
{
    if(showingDetails)
    {
        [self.workoutDaysTableViewController.view removeFromSuperview];
        [self.workoutDaysTableViewController.view setHidden:YES];
    }
    else
    {

        CGRect segmentContainerFrame = self.segmentContainer.frame;
        CGFloat baseYPosition = segmentContainerFrame.origin.y + segmentContainerFrame.size.height + kGEASpaceBetweenLabels;

        if(!self.workoutDaysTableViewController)
        {
            self.workoutDaysTableViewController = [[WorkoutDayTableViewController alloc] initWithWorkoutDays:self.workoutDetail.workoutDays withDelegate:self];

            CGRect workoutDaysFrame = self.workoutDaysTableViewController.view.frame;
            workoutDaysFrame.origin.x = 0.0f;
            workoutDaysFrame.origin.y = baseYPosition;
            workoutDaysFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
            workoutDaysFrame.size.height = [self.workoutDaysTableViewController getHeight];

            [self.workoutDaysTableViewController.view setFrame:workoutDaysFrame];
        }

        [self.scroll addSubview:self.workoutDaysTableViewController.view];
        [self.workoutDaysTableViewController.view setHidden:NO];
    }
}

- (void)updateReviewsData
{
    if(showingDetails)
    {
        [self.reviewsView removeFromSuperview];
        [self.reviewsView setHidden:YES];
    }
    else
    {
        CGRect segmentContainerFrame = self.segmentContainer.frame;
        CGFloat baseYPosition = segmentContainerFrame.origin.y + segmentContainerFrame.size.height + kGEASpaceBetweenLabels;
        CGFloat y = 0;

        if(!self.reviewsView)
        {
            self.reviewsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];

            for(EventReview *review in self.eventReviews)
            {
                EventReviewViewController *ervc = [[EventReviewViewController alloc] initWithEventReview:review];
                [ervc viewDidLoad];
                [ervc.view setFrame:CGRectMake(0, y, [[UIScreen mainScreen] bounds].size.width, [ervc getHeight])];
                [self.reviewsView addSubview:ervc.view];
                y+=[ervc getHeight];
            }

            if(y)
            {
                y+=kGEASpaceBetweenLabels;
                UIImageView *yelp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yelp.png"]];
                [yelp setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2.0f) - (44.0f/2.0f), y, 44.0f, 24.0f)];
                [self.reviewsView addSubview:yelp];
                y+=(yelp.frame.size.height + kGEASpaceBetweenLabels);
            }
        }

        if(!y)  y = self.reviewsView.frame.size.height;

        [self.reviewsView setFrame:CGRectMake(0, baseYPosition, [[UIScreen mainScreen] bounds].size.width, y)];

        [self.scroll addSubview:self.reviewsView];
        [self.reviewsView setHidden:NO];
    }
}

- (void)updateDetailsData
{

    if(showingDetails)
    {
        [self.detailsView setHidden:NO];
        CGRect segmentContainerFrame = self.segmentContainer.frame;
        CGFloat baseYPosition = segmentContainerFrame.origin.y + segmentContainerFrame.size.height + 1.0f;

        [self.workoutType setText:[GEADefinitions retrieveTitleForWorkoutType:self.workout.typeId]];

        [self.workoutFrequency setText:[NSString stringWithFormat:@"%d days / week", self.workout.frequency]];
        [self.workoutDifficulty setText:[GEADefinitions retrieveTitleForWorkoutLevel:self.workout.levelId]];
        [self.workoutMuscles setText:self.workoutDetail.muscles];
        [self.workoutMuscles sizeToFit];

        CGRect detailsViewFrame = self.detailsView.frame;
        detailsViewFrame.origin.y = baseYPosition;
        detailsViewFrame.size.height = CGRectGetMaxY(self.workoutMuscles.frame) + kGEASpaceBetweenLabels;
        [self.detailsView setFrame:detailsViewFrame];
        [self.scroll addSubview:self.detailsView];
    }
    else
    {
        [self.detailsView removeFromSuperview];
        [self.detailsView setHidden:YES];
    }

}

- (void)updateScroll
{
    CGFloat heightSegmentSelectedOption = self.showingDetails ? self.detailsView.frame.size.height : [self.workoutDaysTableViewController getHeight];
    CGFloat scrollContentLength = self.bannerContainer.frame.size.height + self.basicInfoContainer.frame.size.height + kGEASpaceBetweenLabels + self.dealContainer.frame.size.height + self.segmentContainer.frame.size.height + heightSegmentSelectedOption + kGEASpaceBetweenLabels;

    [self.scroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollContentLength)];
    [self.scroll setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.buyContainer.frame.origin.y - 1.0f)];
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

- (void)updateWorkoutDetailData
{
    [self updateBannerData];
    [self updateBasicInfoData];
    [self updateDealData];
    [self updateSegmentControl];
    [self updateDetailsData];
    [self updateWorkoutDaysData];
    [self updateScroll];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.navigationItem.titleView = [[GEALabel alloc] initWithText:[self.workout name] fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];
    
    self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutHud.labelText = @"Loading workout";
    
    self.descriptionButton.layer.borderWidth = 1.0f;
    self.descriptionButton.layer.borderColor = [UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
    self.descriptionButton.layer.cornerRadius = 2.0;
    UIBezierPath *descriptionBackgroundViewShadowPath = [UIBezierPath bezierPathWithRect:self.descriptionButton.bounds];
    self.descriptionButton.layer.shadowPath = descriptionBackgroundViewShadowPath.CGPath;
    
    [self.scroll setHidden:YES];
    [self.buyContainer setHidden:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadWorkoutDetailData];
    });

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
    reviewsView = nil;
    workoutDaysTableViewController = nil;
    popover = nil;
    eventReviews = nil;
}

- (IBAction)showSelectedSegment:(UISegmentedControl *)sender
{
    switch([sender selectedSegmentIndex])
    {
        case DETAILS_SEGMENT_INDEX:         showingDetails = true;
                                            break;

        case WORKOUT_DAYS_SEGMENT_INDEX:    showingDetails = false;
                                            break;
    }

    [self updateWorkoutDetailData];
}

- (IBAction)showDescription:(id)sender
{
    WorkoutDescriptionViewController *edvc = [[WorkoutDescriptionViewController alloc] initWithName:self.workout.name withDescription:self.workoutDetail.workoutDescription];
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
    [self.banner setFrame:bannerFrame];

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
    return 4;
}

- (UIImage *)iconImageInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch (index)
    {
        case 0: return [UIImage imageNamed:@"popover-set-as-current"];
            break;
            
        case 1: return [UIImage imageNamed:@"popover-add-to-favorites"];
            break;
            
        case 2: return [UIImage imageNamed:@"popover-download"];
            break;
            
        case 3: return [UIImage imageNamed:@"popover-send-via-email"];
            break;
    }
    
    return nil;
}

- (NSString *)textInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: return @"Set as current";
            break;
            
        case 1: return @"Save workout";
            break;
            
        case 2: return @"Download";
            break;
            
        case 3: return @"Send via Email";
            break;
    }
    
    return @"";
}

- (void)willSelectRowInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: break;

        case 1: //[self shareWithFacebook];
                break;

        case 2: //[self shareWithTwitter];
                break;

        case 3: break;
    }
}

- (void)willSelectRowInChooseWorkoutDayViewController:(ChooseWorkoutDayViewController *)chooseWorkoutDayViewController atRowIndex:(NSInteger)index
{
    WorkoutPlayViewController *workoutPlayViewController = [[WorkoutPlayViewController alloc] init];
    [self.navigationController pushViewController:workoutPlayViewController animated:NO];
}

- (void)willSelectExerciseInWorkoutDayTableViewController:(WorkoutDayTableViewController *)workoutDayTableViewController withExerciseId:(int)exerciseId
{
    Exercise *exercise = [Exercise getExerciseInfo:exerciseId];
    
    ExerciseDetailViewController *viewController = [[ExerciseDetailViewController alloc] initWithExercise:exercise];
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGRect viewControllerFrame = viewController.navigationController.toolbar.frame;
    viewControllerFrame.origin.y = 20;
    viewController.navigationController.toolbar.frame = viewControllerFrame;
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
