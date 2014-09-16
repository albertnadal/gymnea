//
//  WorkoutPlayResultsViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 31/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutDay+Management.h"
#import "WorkoutDetailViewController.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@protocol WorkoutPlayResultsViewControllerDelegate;

@interface WorkoutPlayResultsViewController : GAITrackedViewController

@property (weak, nonatomic) id<WorkoutPlayResultsViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<WorkoutPlayResultsViewControllerDelegate>)delegate_;

@end

@protocol WorkoutPlayResultsViewControllerDelegate <NSObject>

- (WorkoutDay *)getWorkoutDay:(WorkoutPlayResultsViewController *)workoutPlayResults;
- (void)userDidSelectDiscardResults:(WorkoutPlayResultsViewController *)workoutPlayResults;
- (void)userDidSelectSaveResults:(WorkoutPlayResultsViewController *)workoutPlayResults;
- (int)getGetTotalPlayedExerciseSeconds:(WorkoutPlayResultsViewController *)workoutPlayResults;
- (int)getGetTotalRestSeconds:(WorkoutPlayResultsViewController *)workoutPlayResults;

@end