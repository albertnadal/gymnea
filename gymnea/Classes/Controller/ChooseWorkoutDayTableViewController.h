//
//  ChooseWorkoutDayTableViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseWorkoutDayTableViewControllerDelegate;

@interface ChooseWorkoutDayTableViewController : UITableViewController

@property (weak, nonatomic) id<ChooseWorkoutDayTableViewControllerDelegate>delegate;

- (id)initWithWorkoutDays:(NSArray *)workout_days_ withDelegate:(id<ChooseWorkoutDayTableViewControllerDelegate>)delegate_;

@end

@protocol ChooseWorkoutDayTableViewControllerDelegate <NSObject>

- (void)willSelectRowInChooseWorkoutViewController:(ChooseWorkoutDayTableViewController *)tableViewController atRowIndex:(NSInteger)index;

@end