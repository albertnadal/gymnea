//
//  WorkoutPlayViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "NextExerciseCountdownViewController.h"
#import "WorkoutPlayExerciseViewController.h"
#import "WorkoutPlayRestViewController.h"
#import "WorkoutDay+Management.h"
#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface WorkoutPlayViewController : GAITrackedViewController<NextExerciseCountdownViewControllerDelegate, WorkoutPlayExerciseViewControllerDelegate, WorkoutPlayRestViewControllerDelegate>

- (id)initWithWorkoutDay:(WorkoutDay *)theWorkoutDay;

@end