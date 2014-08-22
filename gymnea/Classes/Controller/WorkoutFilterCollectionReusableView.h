//
//  WorkoutFilterCollectionReusableView.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 22/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GEADefinitions.h"
#import "GenericWorkoutsViewController.h"

@protocol GenericWorkoutsViewControllerDelegate;
@protocol WorkoutFilterCollectionReusableViewDelegate;

@interface WorkoutFilterCollectionReusableView : UICollectionReusableView<GenericWorkoutsViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) id<WorkoutFilterCollectionReusableViewDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIView *containerTypeView;
@property (nonatomic, weak) IBOutlet UIView *containerFrequencyView;
@property (nonatomic, weak) IBOutlet UIView *containerLevelView;
@property (nonatomic, weak) IBOutlet UIButton *typeButton;
@property (nonatomic, weak) IBOutlet UIButton *frequencyButton;
@property (nonatomic, weak) IBOutlet UIButton *levelButton;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

- (IBAction)showWorkoutTypeSelector:(id)sender;
- (IBAction)showWorkoutFrequencySelector:(id)sender;
- (IBAction)showWorkoutLevelSelector:(id)sender;

@end

@protocol WorkoutFilterCollectionReusableViewDelegate <NSObject>

- (void)showWorkoutTypeSelector;
- (void)showWorkoutFrequencySelector;
- (void)showWorkoutLevelSelector;
- (void)searchWorkoutWithText:(NSString *)searchText;
- (void)searchWorkoutWithTextDidBegin;

@end