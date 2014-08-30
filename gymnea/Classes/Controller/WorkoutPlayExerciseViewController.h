//
//  WorkoutPlayExerciseViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkoutPlayExerciseViewControllerDelegate;

@interface WorkoutPlayExerciseViewController : UIViewController

@property (weak, nonatomic) id<WorkoutPlayExerciseViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<WorkoutPlayExerciseViewControllerDelegate>)delegate_;

@end

@protocol WorkoutPlayExerciseViewControllerDelegate <NSObject>

- (int)currentExerciseId:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSString *)currentExerciseName:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)numberOfRepetitionsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)numberOfSetsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)currentSetForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;

/*
- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
*/
- (void)workoutExerciseFinished:(WorkoutPlayExerciseViewController *)workoutExercise;
- (void)userDidSelectFinishWorkoutFromExercise:(WorkoutPlayExerciseViewController *)workoutExercise;

@end