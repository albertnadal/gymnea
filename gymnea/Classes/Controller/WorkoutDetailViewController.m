//
//  WorkoutDetailViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDetailViewController.h"

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

@interface WorkoutDetailViewController ()


@end

@implementation WorkoutDetailViewController

@synthesize workout, workoutDetail, showingDetails, popover, reviewsView, detailsView, workoutDaysTableViewController, exerciseIdDownloadQueue, documentController;

- (id)initWithWorkout:(Workout *)workout_;
{
    if(self = [super initWithNibName:@"WorkoutDetailViewController" bundle:nil])
    {
        showingDetails = true; // Showing 'Details' (default) or 'Reviews'
        popover = nil;
        reviewsView = nil;
        workoutDaysTableViewController = nil;

        self.workout = workout_;
        self.workoutDetail = nil;
        popover = nil;
        self.exerciseIdDownloadQueue = nil;
        self.documentController = nil;
        self.pdfFileURL = nil;
        self.totalWorkoutExercises = 0;
    }

    return self;
}

- (void)setupLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    for(WorkoutDay *workoutDay in self.workoutDetail.workoutDays)
    {
        // weekday 1 => Sunday ... weekday 7 => Saturday
        int weekDay = 0;

        if(([[workoutDay.dayName lowercaseString] isEqualToString:@"monday"]) && (workoutDay.dayNumber == 1)) {
            weekDay = 2; // Monday
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"tuesday"]) && (workoutDay.dayNumber == 2)) {
            weekDay = 3; // Tuesday
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"wednesday"]) && (workoutDay.dayNumber == 3)) {
            weekDay = 4; // Wednesday
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"thursday"]) && (workoutDay.dayNumber == 4)) {
            weekDay = 5; // Thurdsay
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"friday"]) && (workoutDay.dayNumber == 5)) {
            weekDay = 6; // Friday
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"saturday"]) && (workoutDay.dayNumber == 6)) {
            weekDay = 7; // Saturday
        } else if(([[workoutDay.dayName lowercaseString] isEqualToString:@"sunday"]) && (workoutDay.dayNumber == 7)) {
            weekDay = 1; // Sunday
        }

        if(weekDay) {
            NSDictionary *workoutData = @{ @"workoutDayId" : [NSNumber numberWithInteger:workoutDay.workoutDayId], @"name" : workoutDay.title };
            [self notificationWithItem:workoutData withDate:[self setDateForAlarmWithWeekday:weekDay withTime:@"18:00 PM"] andRepeatInterval:NSWeekCalendarUnit];
        }
    }

}

- (void)notificationWithItem:(NSDictionary *)tmpdict withDate:(NSDate *)date andRepeatInterval:(NSCalendarUnit)CalUnit
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];

    if (localNotification==nil) {
        return;
    }

    localNotification.fireDate = date;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatCalendar = [NSCalendar currentCalendar];
    localNotification.alertBody = (NSString *)[tmpdict objectForKey:@"name"];
    localNotification.alertAction = @"Open workout";

    localNotification.repeatInterval = CalUnit;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    //localNotification.soundName=[NSString stringWithFormat:@"%@.caf",[tmpdict objectForKey:@"Tone"]];
    localNotification.userInfo = @{ @"workoutDayId" : [tmpdict objectForKey:@"workoutDayId"] };

    [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
}

- (NSDate*)setDateForAlarmWithWeekday:(int)weekNumber withTime:(NSString *)timeString
{
    NSCalendar *calendar=[NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    
    unsigned currentFlag=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
    
    NSDateComponents *comp=[calendar components:currentFlag fromDate:[NSDate date]];
    
    NSArray *array=[timeString componentsSeparatedByString:@" "];
    NSInteger hour=[[[[array objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:0] intValue];
    NSInteger min=[[[[array objectAtIndex:0] componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    
    if ([[array objectAtIndex:1] isEqualToString:@"PM"]) {
        hour=hour+12;
    }
    else
    {
        if (hour==12) {
            hour=0;
        }
    }
    
    comp.hour=hour;
    comp.minute=min;
    comp.second=0;
    
    int diff=(weekNumber-comp.weekday);
    
    int multiplier;
    if (weekNumber==0) {
        multiplier=0;
    }else
    {
        multiplier=diff>0?diff:(diff==0?diff:diff+7);
    }

    int secondsInOneDay = 86400;
    return [[calendar dateFromComponents:comp]dateByAddingTimeInterval:multiplier*secondsInOneDay];
}

- (void)loadWorkoutDetailData
{
    [[GymneaWSClient sharedInstance] requestWorkoutDetailWithWorkout:self.workout withCompletionBlock:^(GymneaWSClientRequestStatus success, WorkoutDetail *theWorkout) {
        if(success == GymneaWSClientRequestSuccess)
        {
            self.workoutDetail = theWorkout;
            
            [self loadBanner];

            [self.workoutDaysTableViewController.view removeFromSuperview];
            [self.workoutDaysTableViewController.tableView removeFromSuperview];

            // Create the workout days table and force initial reload data
            self.workoutDaysTableViewController = [[WorkoutDayTableViewController alloc] initWithWorkoutDays:self.workoutDetail.workoutDays withDelegate:self];
            [self.workoutDaysTableViewController.tableView reloadData];

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
    if(![self workoutIsDownload]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download is needed"
                                                        message:@"First of all is necessary to download the workout to your device. This will let you to play this workout anywhere without access to Internet."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Download", nil];
        
        [alert setTag:2];
        [alert show];
        
    } else {
        
        ChooseWorkoutDayViewController *chooseWorkoutDayViewController = [[ChooseWorkoutDayViewController alloc] initWithWorkoutDays:self.workoutDetail.workoutDays withDelegate:self];
        [self presentViewController:chooseWorkoutDayViewController animated:YES completion:nil];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 2)
    {
        if(buttonIndex == 1)
        {
            // Download workout
            [self downloadWorkout];
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

- (BOOL)workoutIsDownload
{
    if(self.workoutDetail == nil) return FALSE;

    for(WorkoutDay *workoutDay in self.workoutDetail.workoutDays)
    {
        for(WorkoutDayExercise *workoutDayExercise in workoutDay.workoutDayExercises)
        {
            ExerciseDetail *exerciseDetail = [ExerciseDetail getExerciseDetailInfo:workoutDayExercise.exerciseId];
            if((exerciseDetail == nil) || (exerciseDetail.videoLoop == nil))
            {
                return FALSE;
            }
        }
    }
    

    return TRUE;
}

- (void)showErrorMessageAndCancelDownload
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to reach the network when retrieving the exercises information."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert setTag:1];
    [alert show];
    
    [self.exerciseIdDownloadQueue removeAllObjects];
    self.exerciseIdDownloadQueue = nil;
    
    // Hide HUD after 0.3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self.loadWorkoutHud hide:YES];
    });
}

- (void)downloadNextExerciseFromQueue
{
    if(self.exerciseIdDownloadQueue == nil) return;

    if([self.exerciseIdDownloadQueue count])
    {
        int exerciseId = [(NSNumber *)[self.exerciseIdDownloadQueue objectAtIndex:0] intValue];
        Exercise *exerciseToDownload = [Exercise getExerciseInfo:exerciseId];
        [self.exerciseIdDownloadQueue removeObjectAtIndex:0];

        // Download exercise details
        [[GymneaWSClient sharedInstance] requestExerciseDetailWithExercise:exerciseToDownload
                                                       withCompletionBlock:^(GymneaWSClientRequestStatus success, ExerciseDetail *exerciseDetail) {
            if(success == GymneaWSClientRequestSuccess) {

                // Download exercise video loop
                [[GymneaWSClient sharedInstance] requestExerciseVideoLoopWithExercise:exerciseToDownload
                                                                  withCompletionBlock:^(GymneaWSClientRequestStatus success, NSData *video) {
                                                                      
                                                                      if((success == GymneaWSClientRequestSuccess) && (video != nil)) {
                                                                          exerciseDetail.videoLoop = video;

                                                                          // Flush model changes to db
                                                                          AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                                                                          [appDelegate saveContext];

                                                                          self.loadWorkoutHud.progress = ((self.totalWorkoutExercises - [self.exerciseIdDownloadQueue count]) * 1.0f) / self.totalWorkoutExercises;
                                                                          [self downloadNextExerciseFromQueue];

                                                                      } else {

                                                                          [self showErrorMessageAndCancelDownload];

                                                                      }
                                                                      
                                                                  }];
                
            } else {

                [self showErrorMessageAndCancelDownload];

            }

        }];
    } else {

        // At this point the workout is downloaded
        [self.workout setDownloaded:YES];

        // Flush workout model changes to db
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];

        self.exerciseIdDownloadQueue = nil;
        [self.playWorkoutButton setTitle:@"Start Workout" forState:UIControlStateNormal];

        // Hide HUD after 0.3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

            [self.loadWorkoutHud hide:YES];
        });

    }
}

- (void)downloadWorkout
{
    //Just download the video loop of all the exercises to complete all the missing exercise attributes
    
    self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutHud.mode = MBProgressHUDModeAnnularDeterminate;
    self.loadWorkoutHud.progress = 0.0f;
    self.loadWorkoutHud.labelText = @"Downloading workout";

    self.exerciseIdDownloadQueue = [[NSMutableArray alloc] init];

    for(WorkoutDay *workoutDay in self.workoutDetail.workoutDays)
    {
        for(WorkoutDayExercise *workoutDayExercise in workoutDay.workoutDayExercises)
        {
            ExerciseDetail *exerciseDetail = [ExerciseDetail getExerciseDetailInfo:workoutDayExercise.exerciseId];
            if((exerciseDetail == nil) || (exerciseDetail.videoLoop == nil))
            {
                [self.exerciseIdDownloadQueue addObject:[NSNumber numberWithInteger:workoutDayExercise.exerciseId]];
            }
        }
    }

    self.totalWorkoutExercises = [self.exerciseIdDownloadQueue count];
    [self downloadNextExerciseFromQueue];

}

- (void)downloadWorkoutPDF
{
    //Just download the workout PDF

    self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutHud.labelText = @"Downloading workout PDF";

    [[GymneaWSClient sharedInstance] requestWorkoutPDFWithWorkout:self.workout
                                              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSData *pdf) {

                                                  if((success == GymneaWSClientRequestSuccess) && (pdf != nil)) {

                                                      NSError *error = nil;

                                                      NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
                                                      [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];

                                                      self.pdfFileURL = [directoryURL URLByAppendingPathComponent:@"workout.pdf"];

                                                      [pdf writeToURL:self.pdfFileURL options:NSDataWritingAtomic error:&error];

                                                      if(self.documentController == nil) {
                                                          self.documentController = [[UIDocumentInteractionController alloc] init];
                                                      }

                                                      [self.documentController setURL:self.pdfFileURL];
                                                      documentController.delegate = self;
                                                      documentController.UTI = @"com.adobe.pdf";
                                                      [documentController presentOpenInMenuFromRect:CGRectZero
                                                                                             inView:self.view
                                                                                           animated:YES];

                                                  } else {

                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                      message:@"Unable to reach the network when retrieving the workout PDF."
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

- (void)setAsUserCurrentWorkout
{
    if(self.loadWorkoutHud) {
        [self.loadWorkoutHud hide:YES];
    }

    self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loadWorkoutHud.labelText = @"Setting as current workout";

    [[GymneaWSClient sharedInstance] setUserCurrentWorkoutWithWorkout:self.workout
                                                  withCompletionBlock:^(GymneaWSClientRequestStatus success) {

                                                      // Setup local notifications properly
                                                      [self setupLocalNotifications];

                                                      [self.loadWorkoutHud hide:YES];
                                                  }];
}

- (void)updateBasicInfoData
{
    if(![self workoutIsDownload]) {
        [self.playWorkoutButton setTitle:@"Start Workout (need download)" forState:UIControlStateNormal];
    }

    CGRect bannerContainerFrame = self.bannerContainer.frame;
    CGFloat baseYPosition = bannerContainerFrame.origin.y + bannerContainerFrame.size.height + 1.0f;

    CGRect eventTitleFrame = self.eventTitle.frame;
    eventTitleFrame.size.width = [UIScreen mainScreen].bounds.size.width - (eventTitleFrame.origin.x * 2.0f);
    eventTitleFrame.size.height = 0;
    [self.eventTitle setFrame:eventTitleFrame];

    [self.eventTitle setText:self.workout.name];
    [self.eventTitle sizeToFit];

    eventTitleFrame = self.eventTitle.frame;
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
    else if(self.workoutDaysTableViewController)
    {
        CGRect segmentContainerFrame = self.segmentContainer.frame;
        CGFloat baseYPosition = segmentContainerFrame.origin.y + segmentContainerFrame.size.height + kGEASpaceBetweenLabels;
        
        CGRect workoutDaysFrame = self.workoutDaysTableViewController.view.frame;
        workoutDaysFrame.origin.x = 0.0f;
        workoutDaysFrame.origin.y = baseYPosition;
        workoutDaysFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
        workoutDaysFrame.size.height = [self.workoutDaysTableViewController getHeight];
        
        [self.workoutDaysTableViewController.view setFrame:workoutDaysFrame];
        
        [self.scroll addSubview:self.workoutDaysTableViewController.view];
        [self.workoutDaysTableViewController.view setHidden:NO];
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
    self.scroll.delaysContentTouches = YES;
    self.scroll.canCancelContentTouches = NO;
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

- (void)loadWorkoutView
{
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

    // Remove any existing view of previous workout days table view
    if(self.workoutDaysTableViewController) {
        [self.workoutDaysTableViewController.view removeFromSuperview];
        [self.workoutDaysTableViewController.tableView removeFromSuperview];
    }


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadWorkoutDetailData];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    [self loadWorkoutView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if(self.pdfFileURL != nil) {
        
        // Delete the temporal file used to save the pdf
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.pdfFileURL error:&error];
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
    reviewsView = nil;
    workoutDaysTableViewController = nil;
    popover = nil;
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
            
        case 1: return @"Add to favorites";
            break;
            
        case 2: return @"Download";
            break;
            
        case 3: return @"Workout PDF";
            break;
    }
    
    return @"";
}

- (void)willSelectRowInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index
{
    switch(index)
    {
        case 0: [self setAsUserCurrentWorkout];
                break;

        case 1: //[self shareWithFacebook];
                break;

        case 2: [self downloadWorkout];
                break;

        case 3: if(self.pdfFileURL != nil) {

                    // Delete the temporal file used to save the pdf
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtURL:self.pdfFileURL error:&error];
                }
                [self downloadWorkoutPDF];
                break;
    }
}

- (void)willSelectRowInChooseWorkoutDayViewController:(ChooseWorkoutDayViewController *)chooseWorkoutDayViewController atRowIndex:(NSInteger)index
{

    NSMutableSet *workoutDaysMutableSet = [[NSMutableSet alloc] initWithSet:self.workoutDetail.workoutDays];
    NSSortDescriptor *dayNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:YES];
    NSArray *workoutDaysArray = [workoutDaysMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:dayNumberDescriptor]];
    WorkoutDay *workoutDay = [workoutDaysArray objectAtIndex:index];

    WorkoutPlayViewController *workoutPlayViewController = [[WorkoutPlayViewController alloc] initWithWorkoutDay:workoutDay];
    [self.navigationController pushViewController:workoutPlayViewController animated:YES];
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

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
    
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    
}

@end
