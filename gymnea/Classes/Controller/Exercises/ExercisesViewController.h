//
//  ExercisesViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseDetailViewController.h"
#import "MBProgressHUD.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ExerciseFilterCollectionReusableView.h"
#import "GymneaWSClient.h"
#import "GEADefinitions.h"
#import "Exercise.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@class ExerciseFilterCollectionReusableView;
@protocol ExerciseFilterCollectionReusableViewDelegate;
@protocol ExercisesViewControllerDelegate;

@interface ExercisesViewController : GAITrackedViewController<UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, UIPickerViewDataSource, UIPickerViewDelegate, ExerciseFilterCollectionReusableViewDelegate>
{
    UICollectionView *_collectionView;
    UIView *_disableCollectionView;
    NSArray *exercisesList;
    BOOL needRefreshData;
    BOOL loadingData;

    GymneaExerciseType exerciseType;
    GymneaMuscleType muscleType;
    GymneaEquipmentType equipmentType;
    GymneaExerciseLevel exerciseLevel;
    NSString *searchText;
    
    UIPickerView *exerciseTypePickerView;
    UIView *exerciseTypePickerToolbar;
    
    UIPickerView *musclePickerView;
    UIView *musclePickerToolbar;
    
    UIPickerView *equipmentPickerView;
    UIView *equipmentPickerToolbar;
    
    UIPickerView *exerciseLevelPickerView;
    UIView *exerciseLevelPickerToolbar;
    
}

@property (nonatomic, retain) ExerciseFilterCollectionReusableView *headerView;
@property (nonatomic) BOOL needRefreshData;
@property (nonatomic) BOOL loadingData;
@property (nonatomic, copy) NSArray *exercisesList;
@property (nonatomic, retain) UIPickerView *exerciseTypePickerView;
@property (nonatomic, retain) UIView *exerciseTypePickerToolbar;
@property (nonatomic, retain) UIPickerView *musclePickerView;
@property (nonatomic, retain) UIView *musclePickerToolbar;
@property (nonatomic, retain) UIPickerView *equipmentPickerView;
@property (nonatomic, retain) UIView *equipmentPickerToolbar;
@property (nonatomic, retain) UIPickerView *exerciseLevelPickerView;
@property (nonatomic, retain) UIView *exerciseLevelPickerToolbar;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, weak) IBOutlet UILabel *noExercisesFoundLabel;
@property (weak, nonatomic) id<ExercisesViewControllerDelegate>filterDelegate;
@property (nonatomic, retain) MBProgressHUD *loadExercisesHud;

- (void)reloadData;
- (void)showExerciseDetailsAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)calculateHeightForString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)maxWidth;

@end

@protocol ExercisesViewControllerDelegate <NSObject>

- (void)exerciseTypeNameSelected:(NSString *)name;
- (void)muscleNameSelected:(NSString *)name;
- (void)equipmentNameSelected:(NSString *)name;
- (void)exerciseLevelNameSelected:(NSString *)name;

@end
