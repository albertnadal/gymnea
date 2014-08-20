//
//  ExercisePlayViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 19/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseDetail.h"

@protocol ExercisePlayViewControllerDelegate;

@interface ExercisePlayViewController : UIViewController

@property (weak, nonatomic) id<ExercisePlayViewControllerDelegate>delegate;

- (id)initWithExercise:(Exercise *)exercise_ withDetails:(ExerciseDetail *)details_ withDelegate:(id<ExercisePlayViewControllerDelegate>)delegate_;

@end

@protocol ExercisePlayViewControllerDelegate <NSObject>

- (void)exerciseFinished:(ExercisePlayViewController *)exercisePlay;
- (void)userDidSelectFinishExercise:(ExercisePlayViewController *)exercisePlay;

@end