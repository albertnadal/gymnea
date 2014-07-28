//
//  NextExerciseCountdownViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NextExerciseCountdownViewControllerDelegate;

@interface NextExerciseCountdownViewController : UIViewController

@property (weak, nonatomic) id<NextExerciseCountdownViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<NextExerciseCountdownViewControllerDelegate>)delegate_;

@end

@protocol NextExerciseCountdownViewControllerDelegate <NSObject>

- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (void)nextExerciseCountdownFinished:(NextExerciseCountdownViewController *)nextExerciseCountdown;

//- (void)willSelectRowInPopoverViewController:(NextExerciseCountdownViewController *)popover atRowIndex:(NSInteger)index;

@end