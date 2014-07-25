//
//  WorkoutDayTableViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 23/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventReview.h"

@interface WorkoutDayTableViewController : UITableViewController

- (CGFloat)getHeight;
- (id)initWithWorkoutDays:(EventReview *)workout_days_;

@end
