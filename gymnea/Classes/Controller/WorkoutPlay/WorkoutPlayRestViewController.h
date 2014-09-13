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

- (id)initWithSecondsRest:(int)seconds withDelegate:(id<WorkoutPlayRestViewControllerDelegate>)delegate_;

@end

@protocol WorkoutPlayRestViewControllerDelegate <NSObject>

- (NSString *)nextExerciseNameAfterRest:(WorkoutPlayRestViewController *)workoutExerciseRest;
- (int)nextExerciseIdAfterRest:(WorkoutPlayRestViewController *)workoutExerciseRest;
- (void)workoutExerciseRestFinished:(WorkoutPlayRestViewController *)workoutExerciseRest;
- (void)userDidSelectFinishWorkoutFromRest:(WorkoutPlayRestViewController *)workoutExerciseRest;
- (void)totalSecondsResting:(WorkoutPlayRestViewController *)workoutExerciseRest withSeconds:(int)totalSeconds;

@end