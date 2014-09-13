//
//  ExercisesSavedViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 20/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExercisesViewController.h"

@protocol ExercisesViewControllerDelegate;

@interface ExercisesSavedViewController : ExercisesViewController

@property (weak, nonatomic) id<ExercisesViewControllerDelegate>filterDelegate;

- (void)reloadDataAgain;

@end
