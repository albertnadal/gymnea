//
//  ChooseWorkoutDayViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ChooseWorkoutDayViewController.h"
#import "ChooseWorkoutDayTableViewController.h"
#import "GEALabel+Gymnea.h"

@interface ChooseWorkoutDayViewController ()
{
    ChooseWorkoutDayTableViewController *chooseWorkoutDayTableViewController;
}

@property (nonatomic, strong) ChooseWorkoutDayTableViewController *chooseWorkoutDayTableViewController;
@property (nonatomic, weak) IBOutlet UIView *cancelContainer;
@property (nonatomic, weak) IBOutlet UIView *topLineSeparator;

- (IBAction)cancelWorkout:(id)sender;

@end

@implementation ChooseWorkoutDayViewController

@synthesize chooseWorkoutDayTableViewController;

- (id)init
{
    if(self = [super initWithNibName:@"ChooseWorkoutDayViewController" bundle:nil])
    {
        chooseWorkoutDayTableViewController = nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Choose a workout day" fontSize:18.0f frame:CGRectMake(0.0f,20.0f,[[UIScreen mainScreen] bounds].size.width,44.0f)];
    [self.view addSubview:titleModal];

    CGRect topLineSeparatorFrame = self.topLineSeparator.frame;
    topLineSeparatorFrame.origin.y = CGRectGetMaxY(titleModal.frame);
    [self.view bringSubviewToFront:self.topLineSeparator];

    self.chooseWorkoutDayTableViewController = [[ChooseWorkoutDayTableViewController alloc] init];

    CGRect workoutDaysFrame = self.chooseWorkoutDayTableViewController.view.frame;
    workoutDaysFrame.origin.x = 0.0f;
    workoutDaysFrame.origin.y = CGRectGetMaxY(topLineSeparatorFrame);
    workoutDaysFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
    workoutDaysFrame.size.height = self.cancelContainer.frame.origin.y - CGRectGetMaxY(titleModal.frame);

    [self.chooseWorkoutDayTableViewController.view setFrame:workoutDaysFrame];
    [self.view addSubview:self.chooseWorkoutDayTableViewController.view];
}

- (IBAction)cancelWorkout:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    chooseWorkoutDayTableViewController = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
