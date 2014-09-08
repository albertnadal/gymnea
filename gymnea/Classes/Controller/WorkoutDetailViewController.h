//
//  WorkoutDetailViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutDetailViewController.h"
#import "GEAPopoverViewController.h"
#import "WorkoutDescriptionViewController.h"
#import "WorkoutDayTableViewController.h"
#import "AppDelegate.h"
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

@interface WorkoutDetailViewController : UIViewController <GEAPopoverViewControllerDelegate, UIScrollViewDelegate, ChooseWorkoutDayViewControllerDelegate, WorkoutDayTableViewControllerDelegate, UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>
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
    
    // Exercise download queue
    NSMutableArray *exerciseIdDownloadQueue;
    
    // Document controller for managing the workout PDF
    UIDocumentInteractionController *documentController;
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
@property (nonatomic, retain) MBProgressHUD *loadWorkoutHud;
@property (nonatomic, weak) IBOutlet UIButton *playWorkoutButton;
@property (nonatomic, retain) NSMutableArray *exerciseIdDownloadQueue;
@property (nonatomic) int totalWorkoutExercises;
@property (nonatomic, retain) UIDocumentInteractionController *documentController;
@property (nonatomic, retain) NSURL *pdfFileURL;
@property (nonatomic, retain) IBOutlet UIView *currentWorkoutGuideView;
@property (nonatomic, retain) UIScrollView *currentWorkoutGuideScroll;


- (id)initWithWorkout:(Workout *)workout_;
- (void)loadWorkoutView;
- (void)loadWorkoutDetailData;
- (void)loadBanner;
- (void)updateWorkoutDetailData;
- (void)updateBannerData;
- (void)updateBasicInfoData;
- (void)updateDealData;
- (void)updateSegmentControl;
- (void)updateDetailsData;
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
- (BOOL)workoutIsDownload;
- (void)downloadWorkout;
- (void)downloadNextExerciseFromQueue;
- (void)showErrorMessageAndCancelDownload;
- (void)downloadWorkoutPDF;
- (void)setAsUserCurrentWorkout;
- (void)setupLocalNotifications;
- (NSDate*)setDateForAlarmWithWeekday:(int)weekNumber withTime:(NSString *)timeString;
- (void)notificationWithItem:(NSDictionary *)tmpdict withDate:(NSDate *)date andRepeatInterval:(NSCalendarUnit)CalUnit;

@end
