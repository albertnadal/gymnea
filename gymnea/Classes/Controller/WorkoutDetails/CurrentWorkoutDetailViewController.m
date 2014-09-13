//
//  CurrentWorkoutDetailViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 26/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "CurrentWorkoutDetailViewController.h"
#import "Workout+Management.h"
#import "WorkoutDetail+Management.h"
#import "UserInfo+Management.h"

@implementation CurrentWorkoutDetailViewController

- (id)init
{
    if(self = [super initWithNibName:@"WorkoutDetailViewController" bundle:nil])
    {
        showingDetails = true; // Showing 'Details' (default) or 'Reviews'
        popover = nil;
        reviewsView = nil;
        workoutDaysTableViewController = nil;

        // Loads the user info current workout
        UserInfo *userInfo = [[GymneaWSClient sharedInstance] requestLocalUserInfo];
        //NSLog(@"user info current workout: %d", userInfo.currentWorkoutId);
        self.workout = [userInfo getUserCurrentWorkout];

        self.workoutDetail = nil;
        popover = nil;
        self.exerciseIdDownloadQueue = nil;
        self.documentController = nil;
        self.pdfFileURL = nil;
    }

    return self;
}

- (void)reloadUserInfoCurrentWorkout
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // Move scroll to top
        [self.scroll setContentOffset:CGPointZero animated:NO];

        // Loads the user info current workout
        UserInfo *userInfo = [[GymneaWSClient sharedInstance] requestLocalUserInfo];
        //NSLog(@"user info current workout: %d", userInfo.currentWorkoutId);
        Workout *latest_current_workout = [userInfo getUserCurrentWorkout];

        // If the latest current workout retrieved from the web server is the same locally then there is no necessary to reload
        if((latest_current_workout.workoutId == self.workout.workoutId) && (latest_current_workout != nil)) {
            return;
        }

        if(self.loadWorkoutHud) {
            [self.loadWorkoutHud hide:YES];
        }

        self.navigationItem.titleView = [[GEALabel alloc] initWithText:@"" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

        self.workout = latest_current_workout;

        if(self.workout != nil) {

            // This user have a current workout.
            self.navigationItem.titleView = [[GEALabel alloc] initWithText:[self.workout name] fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

            self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.loadWorkoutHud.labelText = @"Loading current workout";
            
            self.descriptionButton.layer.borderWidth = 1.0f;
            self.descriptionButton.layer.borderColor = [UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
            self.descriptionButton.layer.cornerRadius = 2.0;
            UIBezierPath *descriptionBackgroundViewShadowPath = [UIBezierPath bezierPathWithRect:self.descriptionButton.bounds];
            self.descriptionButton.layer.shadowPath = descriptionBackgroundViewShadowPath.CGPath;
            
            [self.scroll setHidden:YES];
            [self.buyContainer setHidden:YES];
            if(self.currentWorkoutGuideScroll) {
                [self.currentWorkoutGuideScroll setHidden:YES];
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self loadWorkoutDetailData];
            });

        } else {
            // This use doest not have a workout set as current workout. Show the instructions view.

            [self.scroll setHidden:YES];
            [self.buyContainer setHidden:YES];

            if(!self.currentWorkoutGuideScroll) {
                self.currentWorkoutGuideScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height)];
                [self.currentWorkoutGuideScroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, self.currentWorkoutGuideView.frame.size.height)];
                self.currentWorkoutGuideScroll.delaysContentTouches = YES;
                self.currentWorkoutGuideScroll.canCancelContentTouches = NO;
                [self.currentWorkoutGuideScroll addSubview:self.currentWorkoutGuideView];
                [self.view addSubview:self.currentWorkoutGuideScroll];
                [self.currentWorkoutGuideScroll setBackgroundColor:[UIColor whiteColor]];
                [self.currentWorkoutGuideScroll setOpaque:YES];
            }

            [self.currentWorkoutGuideScroll setHidden:NO];

        }

    });
}

- (void)loadWorkoutView
{
    // Listen for incoming new current workout set
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadUserInfoCurrentWorkout)
                                                 name:GEANotificationUserInfoUpdated
                                               object:nil];


    self.navigationItem.titleView = [[GEALabel alloc] initWithText:[self.workout name] fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    self.descriptionButton.layer.borderWidth = 1.0f;
    self.descriptionButton.layer.borderColor = [UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0].CGColor;
    self.descriptionButton.layer.cornerRadius = 2.0;
    UIBezierPath *descriptionBackgroundViewShadowPath = [UIBezierPath bezierPathWithRect:self.descriptionButton.bounds];
    self.descriptionButton.layer.shadowPath = descriptionBackgroundViewShadowPath.CGPath;
    
    [self.scroll setHidden:YES];
    [self.buyContainer setHidden:YES];


    if(self.workout != nil) {

        if(self.loadWorkoutHud) {
            [self.loadWorkoutHud hide:YES];
        }

        self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadWorkoutHud.labelText = @"Loading current workout";
        
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
        
    } else {

        // No current workout assigned yet locally, waiting for server. Show the loading indicator while waiting for the GEANotificationUserInfoUpdated notification.
        if(self.loadWorkoutHud) {
            [self.loadWorkoutHud hide:YES];
        }

        self.loadWorkoutHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.loadWorkoutHud.labelText = @"Checking for current workout";
    }
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
                                                            message:@"Unable to reach the network when retrieving the current workout information."
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

- (void)updateScroll
{
    CGFloat heightSegmentSelectedOption = self.showingDetails ? self.detailsView.frame.size.height : [self.workoutDaysTableViewController getHeight];
    CGFloat scrollContentLength = self.bannerContainer.frame.size.height + self.basicInfoContainer.frame.size.height + kGEASpaceBetweenLabels + self.dealContainer.frame.size.height + self.segmentContainer.frame.size.height + heightSegmentSelectedOption + kGEASpaceBetweenLabels;
    
    [self.scroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollContentLength)];
    
    self.scroll.delaysContentTouches = YES;
    self.scroll.canCancelContentTouches = NO;
}

@end
