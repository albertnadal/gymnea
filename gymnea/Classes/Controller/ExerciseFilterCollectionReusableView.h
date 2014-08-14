//
//  ExerciseFilterCollectionReusableView.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 13/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GEADefinitions.h"
#import "ExercisesViewController.h"

@protocol ExerciseFilterCollectionReusableViewDelegate;

@interface ExerciseFilterCollectionReusableView : UICollectionReusableView<ExercisesViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) id<ExerciseFilterCollectionReusableViewDelegate>delegate;
@property (nonatomic, weak) IBOutlet UIView *containerTypeView;
@property (nonatomic, weak) IBOutlet UIView *containerMuscleView;
@property (nonatomic, weak) IBOutlet UIView *containerEquipmentView;
@property (nonatomic, weak) IBOutlet UIView *containerLevelView;
@property (nonatomic, weak) IBOutlet UIButton *typeButton;
@property (nonatomic, weak) IBOutlet UIButton *muscleButton;
@property (nonatomic, weak) IBOutlet UIButton *equipmentButton;
@property (nonatomic, weak) IBOutlet UIButton *levelButton;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

- (IBAction)showExerciseTypeSelector:(id)sender;
- (IBAction)showMuscleSelector:(id)sender;
- (IBAction)showEquipmentSelector:(id)sender;
- (IBAction)showExerciseLevelSelector:(id)sender;

@end

@protocol ExerciseFilterCollectionReusableViewDelegate <NSObject>

- (void)showExerciseTypeSelector;
- (void)showMuscleSelector;
- (void)showEquipmentSelector;
- (void)showExerciseLevelSelector;
- (void)searchExerciseWithText:(NSString *)searchText;
- (void)searchExerciseWithTextDidBegin;

//- (void)willChangeOptionsInExerciseFilterCollectionReusableView:(ExerciseFilterCollectionReusableView *)reusableView withType:(GymneaExerciseType)typeId withMuscle:(GymneaMuscleType)muscleId withEquipment:(GymneaEquipmentType)equipmentId withLevel:(GymneaExerciseLevel)levelId;

@end