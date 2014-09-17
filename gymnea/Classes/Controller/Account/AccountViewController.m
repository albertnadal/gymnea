//
//  AccountViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "AccountViewController.h"
#import "GEAAuthenticationKeychainStore.h"
#import "Exercise+Management.h"
#import "ExerciseDetail+Management.h"
#import "Workout+Management.h"
#import "WorkoutDetail+Management.h"
#import "WorkoutDayExercise+Management.h"
#import "WorkoutDay+Management.h"
#import "UserInfo+Management.h"
#import "UserPicture+Management.h"
#import "AppDelegate.h"
#import "EditProfileViewController.h"
#import "GymneaWSClient.h"

@interface AccountViewController ()

- (IBAction)doLogout:(id)sender;
- (IBAction)doEditProfile:(id)sender;

@end

@implementation AccountViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)doLogout:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign out confirmation"
                                                    message:@"Do you really want to sign out?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Sign out", nil];

    [alert setTag:1];
    [alert show];
}

- (IBAction)doEditProfile:(id)sender
{
    EditProfileViewController *editProfileViewController = [[EditProfileViewController alloc] init];
    [self presentViewController:editProfileViewController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1)
    {
        if(buttonIndex == 1)
        {
            // Logout
            [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Account"
                                                                                                action:@"SignOut"
                                                                                                 label:@""
                                                                                                 value:nil] build]];
            [[GAI sharedInstance] dispatch];

            [self logout];
        }
    }
}

- (void)logout
{
    // Remove the auth data
    [GEAAuthenticationKeychainStore clearAllData];

    // Remove the session ID
    [[GymneaWSClient sharedInstance] setSessionId:@""];

    // Delete all DB data
    [Exercise deleteAll];
    [ExerciseDetail deleteAll];
    [Workout deleteAll];
    [WorkoutDetail deleteAll];
    [WorkoutDay deleteAll];
    [WorkoutDayExercise deleteAll];
    [UserPicture deleteAll];
    [UserInfo deleteAll];

    // Save Core Data context
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];

    // Show initial view
    [appDelegate performSelector:@selector(showInitialView) withObject:nil afterDelay:0.1f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.screenName = @"AccountViewController";
}

@end
