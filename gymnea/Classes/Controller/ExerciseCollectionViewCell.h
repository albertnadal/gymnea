//
//  ExerciseCollectionViewCell.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTitle;
@property (nonatomic, weak) IBOutlet UIView *attributesView;
@property (nonatomic, weak) IBOutlet UILabel *exerciseType;
@property (nonatomic, weak) IBOutlet UIView *separator;
@property (nonatomic, weak) IBOutlet UILabel *exerciseMuscle;
@property (nonatomic, weak) IBOutlet UILabel *exerciseEquipment;
@property (nonatomic, weak) IBOutlet UILabel *exerciseLevel;


@end
