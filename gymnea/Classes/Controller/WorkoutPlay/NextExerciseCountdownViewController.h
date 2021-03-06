//
//  NextExerciseCountdownViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@protocol NextExerciseCountdownViewControllerDelegate;

@interface NextExerciseCountdownViewController : GAITrackedViewController

@property (weak, nonatomic) id<NextExerciseCountdownViewControllerDelegate>delegate;

- (id)initWithDelegate:(id<NextExerciseCountdownViewControllerDelegate>)delegate_;

@end

@protocol NextExerciseCountdownViewControllerDelegate <NSObject>

- (NSInteger)numberOfSecondsToCoundown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseName:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSInteger)nextExerciseTotalRepetitions:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (NSString *)nextExerciseSetsRepetitionsString:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (int)nextExerciseId:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (void)nextExerciseCountdownFinished:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (void)userDidSelectFinishWorkoutFromCountdown:(NextExerciseCountdownViewController *)nextExerciseCountdown;
- (void)totalSecondsResting:(NextExerciseCountdownViewController *)nextExerciseCountdown withSeconds:(int)totalSeconds;

@end