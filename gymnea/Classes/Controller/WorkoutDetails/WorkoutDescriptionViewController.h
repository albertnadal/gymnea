//
//  WorkoutDescriptionViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 12/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface WorkoutDescriptionViewController : GAITrackedViewController

- (id)initWithName:(NSString *)exerciseName withDescription:(NSString *)exerciseDescription;

@end
