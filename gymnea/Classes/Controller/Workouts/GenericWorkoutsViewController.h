//
//  GenericWorkoutsViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

/*#import <UIKit/UIKit.h>

@interface GenericWorkoutsViewController : UIViewController

@end*/

#import <UIKit/UIKit.h>
#import "ExerciseDetailViewController.h"
#import "MBProgressHUD.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "WorkoutFilterCollectionReusableView.h"
#import "GymneaWSClient.h"
#import "GEADefinitions.h"
#import "Workout.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@class WorkoutFilterCollectionReusableView;
@protocol WorkoutFilterCollectionReusableViewDelegate;
@protocol GenericWorkoutsViewControllerDelegate;

@interface GenericWorkoutsViewController : GAITrackedViewController<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, UIPickerViewDataSource, UIPickerViewDelegate, WorkoutFilterCollectionReusableViewDelegate>
{
    UICollectionView *_collectionView;
    UIView *_disableCollectionView;
    NSArray *workoutsList;
    BOOL needRefreshData;
    BOOL loadingData;
    
    GymneaWorkoutType workoutType;
    int workoutFrequency;
    GymneaWorkoutLevel workoutLevel;
    NSString *searchText;
    
    UIPickerView *workoutTypePickerView;
    UIView *workoutTypePickerToolbar;
    
    UIPickerView *musclePickerView;
    UIView *musclePickerToolbar;
    
    UIPickerView *equipmentPickerView;
    UIView *equipmentPickerToolbar;
    
    UIPickerView *workoutLevelPickerView;
    UIView *workoutLevelPickerToolbar;
}

@property (nonatomic, retain) WorkoutFilterCollectionReusableView *headerView;
@property (nonatomic) BOOL needRefreshData;
@property (nonatomic) BOOL loadingData;
@property (nonatomic, copy) NSArray *workoutsList;
@property (nonatomic, retain) UIPickerView *workoutTypePickerView;
@property (nonatomic, retain) UIView *workoutTypePickerToolbar;
@property (nonatomic, retain) UIPickerView *frequencyPickerView;
@property (nonatomic, retain) UIView *frequencyPickerToolbar;
@property (nonatomic, retain) UIPickerView *workoutLevelPickerView;
@property (nonatomic, retain) UIView *workoutLevelPickerToolbar;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, weak) IBOutlet UILabel *noWorkoutsFoundLabel;
@property (weak, nonatomic) id<GenericWorkoutsViewControllerDelegate>filterDelegate;
@property (nonatomic, retain) MBProgressHUD *loadWorkoutsHud;

- (void)reloadData;
- (void)showWorkoutDetailsAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)calculateHeightForString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)maxWidth;

@end

@protocol GenericWorkoutsViewControllerDelegate <NSObject>

- (void)workoutTypeNameSelected:(NSString *)name;
- (void)workoutFrequencyNameSelected:(NSString *)name;
- (void)workoutLevelNameSelected:(NSString *)name;

@end
