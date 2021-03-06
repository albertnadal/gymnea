//
//  WorkoutPlayViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayViewController.h"
#import "WorkoutPlayTableViewController.h"
#import "WorkoutPlayResultsViewController.h"
#import "WorkoutDayExercise+Management.h"
#import "GymneaWSClient.h"
#import "Exercise+Management.h"
#import "GEALabel+Gymnea.h"


@interface WorkoutPlayViewController ()<WorkoutPlayResultsViewControllerDelegate>
{
    WorkoutDay *workoutDay;
    WorkoutPlayTableViewController *workoutPlayTableViewController;

    NSArray *workoutDaySequence;
    int indexCurrentExercise;
    int indexCurrentExerciseSet;

    int totalSecondsPlayingExercises;
    int totalSecondsResting;
}

@property (nonatomic, retain) WorkoutDay *workoutDay;
@property (nonatomic, strong) WorkoutPlayTableViewController *workoutPlayTableViewController;
@property (nonatomic, retain) NSArray *workoutDaySequence;
@property (nonatomic, weak) IBOutlet UIView *startContainerView;

- (IBAction)startWorkout:(id)sender;
- (NSArray *)generateSequenceFromWorkoutDay:(WorkoutDay *)theWorkoutDay;

@end

@implementation WorkoutPlayViewController

@synthesize workoutDay;
@synthesize workoutPlayTableViewController;
@synthesize workoutDaySequence;

- (id)initWithWorkoutDay:(WorkoutDay *)theWorkoutDay
{
    self = [super initWithNibName:@"WorkoutPlayViewController" bundle:nil];
    if (self) {

        self.workoutPlayTableViewController = nil;
        self.workoutDay = theWorkoutDay;
        self.workoutDaySequence = [self generateSequenceFromWorkoutDay:self.workoutDay];

        indexCurrentExercise = 0;
        indexCurrentExerciseSet = 0;

        totalSecondsPlayingExercises = 0;
        totalSecondsResting = 0;
    }
    return self;
}

- (NSArray *)generateSequenceFromWorkoutDay:(WorkoutDay *)theWorkoutDay
{
    NSMutableArray *workoutDaySequenceTemp = [[NSMutableArray alloc] init];

    // Sort exercises by the order key
    NSMutableSet *exercisesMutableSet = [[NSMutableSet alloc] initWithSet:self.workoutDay.workoutDayExercises];
    NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *workoutDayExercisesArray = [exercisesMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderDescriptor]];

    for(WorkoutDayExercise *workoutDayExercise in workoutDayExercisesArray)
    {
        NSMutableArray *exerciseSetArray = [[NSMutableArray alloc] init];

        NSString *repetitionsString = [workoutDayExercise.reps stringByReplacingOccurrencesOfString:@" " withString:@""];
        repetitionsString = [repetitionsString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSArray *repetitionsArray = [repetitionsString componentsSeparatedByString:@","];
        NSNumber *exerciseId = [NSNumber numberWithInt:workoutDayExercise.exerciseId];
        NSNumber *exerciseRestTime = [NSNumber numberWithInt:workoutDayExercise.time];

        if([repetitionsArray count]) {

            for(NSString *repetitionsString in repetitionsArray)
            {
                NSNumber *repetitions = [NSNumber numberWithInt:[repetitionsString intValue]];
                [exerciseSetArray addObject:@{ @"exerciseId" : exerciseId, @"repetitions" : repetitions, @"rest" : exerciseRestTime}];
            }

            [workoutDaySequenceTemp addObject:exerciseSetArray];

        } else {

            [workoutDaySequenceTemp addObject:@{ @"exerciseId" : exerciseId, @"repetitions" : [NSNumber numberWithInt:1], @"rest" : exerciseRestTime }];

        }

    }

    return [NSArray arrayWithArray:workoutDaySequenceTemp];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect startContainerViewFrame = self.startContainerView.frame;
    startContainerViewFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 44.0f - 20.0f - CGRectGetHeight(startContainerViewFrame);
    self.startContainerView.frame = startContainerViewFrame;    
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.titleView = [[GEALabel alloc] initWithText:self.workoutDay.title fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (IBAction)startWorkout:(id)sender
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"WorkoutPlay"
                                                                                        action:@"Start Workout"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

    NextExerciseCountdownViewController *nextExerciseCountdownViewController = [[NextExerciseCountdownViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:nextExerciseCountdownViewController animated:NO];
}

- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    if((!indexCurrentExercise) && (!indexCurrentExerciseSet)) {
        // first exercise of the workout, quick start of 5 seconds countdown
        return 5; // 5 initial seconds to start the workout routine
    } else {
        return 60;
    }
}

- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];

    Exercise *exercise =[Exercise getExerciseInfo:[(NSNumber *)[exerciseInfo objectForKey:@"exerciseId"] intValue]];
    return exercise.name;
}

- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    return [exerciseSetArray count];
}

- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];

    NSString *repetitionsString = @"";
    BOOL isFirstExercise = TRUE;
    for(NSDictionary *exerciseInfo in exerciseSetArray)
    {
        if(isFirstExercise){
            repetitionsString = [repetitionsString stringByAppendingString:[(NSNumber *)[exerciseInfo objectForKey:@"repetitions"] stringValue]];
            isFirstExercise = FALSE;
        } else {
            repetitionsString = [repetitionsString stringByAppendingFormat:@", %d", [(NSNumber *)[exerciseInfo objectForKey:@"repetitions"] intValue]];
        }
    }

    return repetitionsString;
}

- (int)nextExerciseId:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    return [[exerciseInfo objectForKey:@"exerciseId"] intValue];
}

- (void)nextExerciseCountdownFinished:(NextExerciseCountdownViewController *)nextExerciseCountdown
{

    [self.navigationController popToViewController:self animated:NO];

    WorkoutPlayExerciseViewController *workoutPlayExerciseViewController = [[WorkoutPlayExerciseViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayExerciseViewController animated:NO];

}

#pragma WorkoutPlayExerciseViewControllerDelegate

- (void)totalSecondsPlayingExercise:(WorkoutPlayExerciseViewController *)workoutExercise withSeconds:(int)totalSeconds
{
    totalSecondsPlayingExercises += totalSeconds;
}

- (void)workoutExerciseFinished:(WorkoutPlayExerciseViewController *)workoutExercise
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"WorkoutPlay"
                                                                                        action:@"Exercise Finished"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

    // Check first if workout has finished
    if([self.workoutDaySequence count] == indexCurrentExerciseSet + 1) {

        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"WorkoutPlay"
                                                                                            action:@"Workout Finished"
                                                                                             label:@""
                                                                                             value:nil] build]];
        [[GAI sharedInstance] dispatch];

        WorkoutPlayResultsViewController *workoutPlayResultsViewController = [[WorkoutPlayResultsViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:workoutPlayResultsViewController animated:YES];
        return;
    }

    [self.navigationController popToViewController:self animated:NO];

    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    int currentExerciseRest = [[exerciseInfo objectForKey:@"rest"] intValue];

    // Move indexes to next exercise set or exercise repetition
    NSArray *currentExerciseSet = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    if(indexCurrentExercise >= [currentExerciseSet count] - 1) {
        // Current set completed
        indexCurrentExerciseSet++;
        indexCurrentExercise = 0;

        NextExerciseCountdownViewController *nextExerciseCountdownViewController = [[NextExerciseCountdownViewController alloc] initWithDelegate:self];
        [self.navigationController pushViewController:nextExerciseCountdownViewController animated:NO];

    } else {
        // Current exercise set not finished yet
        indexCurrentExercise ++;

        WorkoutPlayRestViewController *workoutPlayRestViewController = [[WorkoutPlayRestViewController alloc] initWithSecondsRest:currentExerciseRest withDelegate:self];
        [self.navigationController pushViewController:workoutPlayRestViewController animated:NO];

    }

}

- (void)userDidSelectFinishWorkoutFromExercise:(WorkoutPlayExerciseViewController *)workoutExercise
{
    self.navigationController.navigationBar.hidden = FALSE;
    
    //    [self.navigationController popToViewController:self animated:NO];
}

- (void)userDidSelectFinishWorkoutFromCountdown:(NextExerciseCountdownViewController *)nextExerciseCountdown
{
    self.navigationController.navigationBar.hidden = FALSE;
    
    //    [self.navigationController popToViewController:self animated:NO];
}

- (NSInteger)numberOfSetsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise
{
    return [(NSArray *)[self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet] count];
}

- (NSInteger)currentSetForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise
{
    return indexCurrentExercise + 1;
}

- (int)currentExerciseId:(WorkoutPlayExerciseViewController *)currentExercise
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    return [[exerciseInfo objectForKey:@"exerciseId"] intValue];
}

- (NSString *)currentExerciseName:(WorkoutPlayExerciseViewController *)currentExercise
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    Exercise *exercise =[Exercise getExerciseInfo:[(NSNumber *)[exerciseInfo objectForKey:@"exerciseId"] intValue]];
    return exercise.name;
}

- (NSInteger)numberOfRepetitionsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    return [(NSNumber *)[exerciseInfo objectForKey:@"repetitions"] intValue];
}

#pragma WorkoutPlayRestViewControllerDelegate

- (void)totalSecondsResting:(WorkoutPlayRestViewController *)workoutExerciseRest withSeconds:(int)totalSeconds
{
    totalSecondsResting += totalSeconds;
}

- (void)userDidSelectFinishWorkoutFromRest:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    self.navigationController.navigationBar.hidden = FALSE;
}

- (void)workoutExerciseRestFinished:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    [self.navigationController popToViewController:self animated:NO];
    
    WorkoutPlayExerciseViewController *workoutPlayExerciseViewController = [[WorkoutPlayExerciseViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:workoutPlayExerciseViewController animated:NO];
}

- (NSString *)nextExerciseNameAfterRest:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    Exercise *exercise =[Exercise getExerciseInfo:[(NSNumber *)[exerciseInfo objectForKey:@"exerciseId"] intValue]];
    return exercise.name;
}

- (int)nextExerciseIdAfterRest:(WorkoutPlayRestViewController *)workoutExerciseRest
{
    NSArray *exerciseSetArray = [self.workoutDaySequence objectAtIndex:indexCurrentExerciseSet];
    NSDictionary *exerciseInfo = [exerciseSetArray objectAtIndex:indexCurrentExercise];
    
    return [[exerciseInfo objectForKey:@"exerciseId"] intValue];
}

#pragma WorkoutPlayResultsViewControllerDelegate

- (int)getGetTotalPlayedExerciseSeconds:(WorkoutPlayResultsViewController *)workoutPlayResults
{
    return totalSecondsPlayingExercises;
}

- (int)getGetTotalRestSeconds:(WorkoutPlayResultsViewController *)workoutPlayResults
{
    return totalSecondsResting;
}

- (WorkoutDay *)getWorkoutDay:(WorkoutPlayResultsViewController *)workoutPlayResults
{
    return self.workoutDay;
}

- (void)userDidSelectDiscardResults:(WorkoutPlayResultsViewController *)workoutPlayResults
{
    // Implement
}

- (void)userDidSelectSaveResults:(WorkoutPlayResultsViewController *)workoutPlayResults
{
    // Implement
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"WorkoutPlayViewController";
}

@end