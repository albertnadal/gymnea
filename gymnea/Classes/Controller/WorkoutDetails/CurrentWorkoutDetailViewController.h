//
//  CurrentWorkoutDetailViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 26/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutDetailViewController.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface CurrentWorkoutDetailViewController : WorkoutDetailViewController

- (void)reloadUserInfoCurrentWorkout;

@end
