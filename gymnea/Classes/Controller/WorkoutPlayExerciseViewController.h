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

/*
- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
*/
- (void)workoutExerciseFinished:(WorkoutPlayExerciseViewController *)workoutExercise;
- (void)userDidSelectFinishWorkoutFromExercise:(WorkoutPlayExerciseViewController *)workoutExercise;

@end