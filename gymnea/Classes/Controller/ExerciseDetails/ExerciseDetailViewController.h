//
//  ExerciseDetailViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 04/08/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface ExerciseDetailViewController : GAITrackedViewController

- (id)initWithExercise:(Exercise *)exercise_ showPlayButton:(BOOL)show;

@end
