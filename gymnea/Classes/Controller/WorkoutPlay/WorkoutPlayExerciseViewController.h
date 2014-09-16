//
//  WorkoutPlayExerciseViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@protocol WorkoutPlayExerciseViewControllerDelegate;

@interface WorkoutPlayExerciseViewController : GAITrackedViewController

@property (weak, nonatomic) id<WorkoutPlayExerciseViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<WorkoutPlayExerciseViewControllerDelegate>)delegate_;

@end

@protocol WorkoutPlayExerciseViewControllerDelegate <NSObject>

- (int)currentExerciseId:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSString *)currentExerciseName:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)numberOfRepetitionsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)numberOfSetsForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;
- (NSInteger)currentSetForCurrentExercise:(WorkoutPlayExerciseViewController *)currentExercise;
- (void)workoutExerciseFinished:(WorkoutPlayExerciseViewController *)workoutExercise;
- (void)userDidSelectFinishWorkoutFromExercise:(WorkoutPlayExerciseViewController *)workoutExercise;
- (void)totalSecondsPlayingExercise:(WorkoutPlayExerciseViewController *)workoutExercise withSeconds:(int)totalSeconds;

@end