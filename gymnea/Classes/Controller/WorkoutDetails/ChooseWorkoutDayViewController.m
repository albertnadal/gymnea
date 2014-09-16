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

@interface ChooseWorkoutDayViewController ()<ChooseWorkoutDayTableViewControllerDelegate>
{
    NSArray *workoutDays;
    ChooseWorkoutDayTableViewController *chooseWorkoutDayTableViewController;
}

@property (nonatomic, strong) NSArray *workoutDays;
@property (nonatomic, strong) ChooseWorkoutDayTableViewController *chooseWorkoutDayTableViewController;
@property (nonatomic, weak) IBOutlet UIView *cancelContainer;
@property (nonatomic, weak) IBOutlet UIView *topLineSeparator;

- (IBAction)cancelWorkout:(id)sender;

@end

@implementation ChooseWorkoutDayViewController

@synthesize chooseWorkoutDayTableViewController;
@synthesize workoutDays;

- (id)initWithWorkoutDays:(NSSet *)workout_days_ withDelegate:(id<ChooseWorkoutDayViewControllerDelegate>)delegate_
{
    if(self = [super initWithNibName:@"ChooseWorkoutDayViewController" bundle:nil])
    {
        chooseWorkoutDayTableViewController = nil;
        self.delegate = delegate_;

        // Sort workout days by day number {0..7}
        NSMutableSet *workoutDaysMutableSet = [[NSMutableSet alloc] initWithSet:workout_days_];
        NSSortDescriptor *dayNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:YES];
        self.workoutDays = [workoutDaysMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:dayNumberDescriptor]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Choose a workout day to play" fontSize:18.0f frame:CGRectMake(0.0f,20.0f,[[UIScreen mainScreen] bounds].size.width,44.0f)];
    [self.view addSubview:titleModal];

    CGRect topLineSeparatorFrame = self.topLineSeparator.frame;
    topLineSeparatorFrame.origin.y = CGRectGetMaxY(titleModal.frame);
    [self.view bringSubviewToFront:self.topLineSeparator];

    self.chooseWorkoutDayTableViewController = [[ChooseWorkoutDayTableViewController alloc] initWithWorkoutDays:self.workoutDays withDelegate:self]; //initWithDelegate:self];

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
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ChooseWorkoutDay"
                                                                                        action:@"Cancel"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

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

- (void)willSelectRowInChooseWorkoutViewController:(ChooseWorkoutDayTableViewController *)tableViewController atRowIndex:(NSInteger)index
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.delegate willSelectRowInChooseWorkoutDayViewController:self atRowIndex:index];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"ChooseWorkoutDayViewController";
}

@end
