//
//  GenericWorkoutsSavedViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 26/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericWorkoutsViewController.h"

@class WorkoutFilterCollectionReusableView;
@protocol WorkoutFilterCollectionReusableViewDelegate;
@protocol GenericWorkoutsViewControllerDelegate;

@interface GenericWorkoutsSavedViewController : GenericWorkoutsViewController

@property (weak, nonatomic) id<GenericWorkoutsViewControllerDelegate>filterDelegate;

- (void)reloadDataAgain;

@end
