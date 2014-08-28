//
//  ChooseWorkoutDayViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseWorkoutDayViewControllerDelegate;

@interface ChooseWorkoutDayViewController : UIViewController

@property (weak, nonatomic) id<ChooseWorkoutDayViewControllerDelegate>delegate;

- (id)initWithWorkoutDays:(NSSet *)workout_days_ withDelegate:(id<ChooseWorkoutDayViewControllerDelegate>)delegate_;

@end

@protocol ChooseWorkoutDayViewControllerDelegate <NSObject>

/*
- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
*/

- (void)willSelectRowInChooseWorkoutDayViewController:(ChooseWorkoutDayViewController *)chooseWorkoutDayViewController atRowIndex:(NSInteger)index;

@end