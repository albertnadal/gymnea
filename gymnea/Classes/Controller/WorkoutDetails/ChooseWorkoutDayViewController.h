//
//  ChooseWorkoutDayViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@protocol ChooseWorkoutDayViewControllerDelegate;

@interface ChooseWorkoutDayViewController : GAITrackedViewController

@property (weak, nonatomic) id<ChooseWorkoutDayViewControllerDelegate>delegate;

- (id)initWithWorkoutDays:(NSSet *)workout_days_ withDelegate:(id<ChooseWorkoutDayViewControllerDelegate>)delegate_;

@end

@protocol ChooseWorkoutDayViewControllerDelegate <NSObject>

- (void)willSelectRowInChooseWorkoutDayViewController:(ChooseWorkoutDayViewController *)chooseWorkoutDayViewController atRowIndex:(NSInteger)index;

@end