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
#import <UIKit/UIKit.h>


@interface WorkoutPlayViewController : UIViewController<NextExerciseCountdownViewControllerDelegate, WorkoutPlayExerciseViewControllerDelegate, WorkoutPlayRestViewControllerDelegate>

- (id)init;

@end
