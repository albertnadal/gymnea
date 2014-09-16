//
//  ExerciseDescriptionViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 04/08/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface ExerciseDescriptionViewController : GAITrackedViewController

- (id)initWithName:(NSString *)exerciseName withDescription:(NSString *)exerciseDescription;

@end
