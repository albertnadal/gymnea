//
//  GenericWorkoutsDownloadedViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 26/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericWorkoutsViewController.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@class WorkoutFilterCollectionReusableView;
@protocol WorkoutFilterCollectionReusableViewDelegate;
@protocol GenericWorkoutsViewControllerDelegate;

@interface GenericWorkoutsDownloadedViewController : GenericWorkoutsViewController

@property (weak, nonatomic) id<GenericWorkoutsViewControllerDelegate>filterDelegate;

- (void)reloadDataAgain;

@end
