//
//  WorkoutDayTableViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 23/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkoutDayTableViewControllerDelegate;

@interface WorkoutDayTableViewController : UITableViewController

@property (weak, nonatomic) id<WorkoutDayTableViewControllerDelegate>delegate;

- (CGFloat)getHeight;
- (id)initWithWorkoutDays:(NSSet *)workout_days_ withDelegate:(id<WorkoutDayTableViewControllerDelegate>)delegate_;

@end

@protocol WorkoutDayTableViewControllerDelegate <NSObject>

- (void)willSelectExerciseInWorkoutDayTableViewController:(WorkoutDayTableViewController *)workoutDayTableViewController withExerciseId:(int)exerciseId;

@end

