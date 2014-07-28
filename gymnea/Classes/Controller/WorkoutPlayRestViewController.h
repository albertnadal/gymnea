//
//  WorkoutPlayRestViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkoutPlayRestViewControllerDelegate;

@interface WorkoutPlayRestViewController : UIViewController

@property (weak, nonatomic) id<WorkoutPlayRestViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<WorkoutPlayRestViewControllerDelegate>)delegate_;

@end

@protocol WorkoutPlayRestViewControllerDelegate <NSObject>

/*
 - (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
 - (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
 - (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
 - (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
 */
- (void)workoutExerciseRestFinished:(WorkoutPlayRestViewController *)workoutExerciseRest;

@end