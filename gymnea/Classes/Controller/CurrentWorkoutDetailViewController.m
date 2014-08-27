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
        NSLog(@"user info current workout: %d", userInfo.currentWorkoutId);
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // Loads the user info current workout
        UserInfo *userInfo = [[GymneaWSClient sharedInstance] requestLocalUserInfo];
        NSLog(@"user info current workout: %d", userInfo.currentWorkoutId);
        Workout *latest_current_workout = [userInfo getUserCurrentWorkout];

        // If the latest current workout retrieved from the web server is the same locally then there is no necessary to reload
        if(latest_current_workout.workoutId == self.workout.workoutId) {
            return;
        }

        self.workout = latest_current_workout;

        self.navigationItem.titleView = [[GEALabel alloc] initWithText:[self.workout name] fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

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
        
    }
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

@end