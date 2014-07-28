//
//  WorkoutPlayViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayViewController.h"


@interface WorkoutPlayViewController ()

@end

@implementation WorkoutPlayViewController

- (id)init
{
    self = [super initWithNibName:@"WorkoutPlayViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = TRUE;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    NextExerciseCountdownViewController *nextExerciseCountdownViewController = [[NextExerciseCountdownViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:nextExerciseCountdownViewController animated:NO];

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

- (void)workoutExerciseRestFinished:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    [self.navigationController popToViewController:self animated:NO];

    WorkoutPlayExerciseViewController *workoutPlayExerciseViewController = [[WorkoutPlayExerciseViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayExerciseViewController animated:NO];
}

@end