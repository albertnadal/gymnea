//
//  ExercisesViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExercisesViewControllerDelegate;

@interface ExercisesViewController : UIViewController

@property (weak, nonatomic) id<ExercisesViewControllerDelegate>filterDelegate;

@end

@protocol ExercisesViewControllerDelegate <NSObject>

- (void)exerciseTypeNameSelected:(NSString *)name;
- (void)muscleNameSelected:(NSString *)name;
- (void)equipmentNameSelected:(NSString *)name;
- (void)exerciseLevelNameSelected:(NSString *)name;

@end
