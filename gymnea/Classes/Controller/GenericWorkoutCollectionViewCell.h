//
//  GenericWorkoutCollectionViewCell.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 29/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericWorkoutCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UILabel *workoutTitle;
@property (nonatomic, weak) IBOutlet UIView *attributesView;
@property (nonatomic, weak) IBOutlet UILabel *workoutType;
@property (nonatomic, weak) IBOutlet UIView *separator;
@property (nonatomic, weak) IBOutlet UILabel *workoutFrequency;;
@property (nonatomic, weak) IBOutlet UILabel *workoutLevel;

@end
