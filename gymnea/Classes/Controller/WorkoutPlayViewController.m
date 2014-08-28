//
//  WorkoutPlayViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayViewController.h"
#import "WorkoutPlayTableViewController.h"
#import "GEALabel+Gymnea.h"


@interface WorkoutPlayViewController ()
{
    WorkoutDay *workoutDay;
    WorkoutPlayTableViewController *workoutPlayTableViewController;
}

@property (nonatomic, retain) WorkoutDay *workoutDay;
@property (nonatomic, strong) WorkoutPlayTableViewController *workoutPlayTableViewController;
@property (nonatomic, weak) IBOutlet UIView *startContainerView;

- (IBAction)startWorkout:(id)sender;

@end

@implementation WorkoutPlayViewController

@synthesize workoutDay;
@synthesize workoutPlayTableViewController;

- (id)initWithWorkoutDay:(WorkoutDay *)theWorkoutDay
{
    self = [super initWithNibName:@"WorkoutPlayViewController" bundle:nil];
    if (self) {

        self.workoutPlayTableViewController = nil;
        self.workoutDay = theWorkoutDay;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.titleView = [[GEALabel alloc] initWithText:self.workoutDay.title fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.workoutPlayTableViewController = [[WorkoutPlayTableViewController alloc] initWithExercises:self.workoutDay.workoutDayExercises];

    CGRect workoutDayFrame = self.workoutPlayTableViewController.view.frame;
    workoutDayFrame.origin.x = 0.0f;
    workoutDayFrame.origin.y = 0.0f;
    workoutDayFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
    workoutDayFrame.size.height = self.startContainerView.frame.origin.y;
    
    [self.workoutPlayTableViewController.view setFrame:workoutDayFrame];
    [self.view addSubview:self.workoutPlayTableViewController.view];
    [self.view bringSubviewToFront:self.startContainerView];

}

- (IBAction)startWorkout:(id)sender
{
    NextExerciseCountdownViewController *nextExerciseCountdownViewController = [[NextExerciseCountdownViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:nextExerciseCountdownViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    return 5;
}

- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    return nil;
}

- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    return 0;
}

- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    return nil;
}

- (void)nextExerciseCountdownFinished:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    [self.navigationController popToViewController:self animated:NO];

    WorkoutPlayExerciseViewController *workoutPlayExerciseViewController = [[WorkoutPlayExerciseViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayExerciseViewController animated:NO];
}

- (void)workoutExerciseFinished:(WorkoutPlayExerciseViewController *)workoutExercise
{
    [self.navigationController popToViewController:self animated:NO];

    WorkoutPlayRestViewController *workoutPlayRestViewController = [[WorkoutPlayRestViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayRestViewController animated:NO];
}

- (void)userDidSelectFinishWorkoutFromExercise:(WorkoutPlayExerciseViewController *)workoutExercise
{
    self.navigationController.navigationBar.hidden = FALSE;

//    [self.navigationController popToViewController:self animated:NO];
}

- (void)userDidSelectFinishWorkoutFromRest:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    self.navigationController.navigationBar.hidden = FALSE;

//    [self.navigationController popToViewController:self animated:NO];
}

- (void)workoutExerciseRestFinished:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    [self.navigationController popToViewController:self animated:NO];

    WorkoutPlayExerciseViewController *workoutPlayExerciseViewController = [[WorkoutPlayExerciseViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayExerciseViewController animated:NO];
}

@end