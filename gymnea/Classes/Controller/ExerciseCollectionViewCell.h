//
//  ExerciseCollectionViewCell.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *thumbnail;
@property (nonatomic, strong) IBOutlet UILabel *exerciseTitle;
@property (nonatomic, strong) IBOutlet UIView *attributesView;
@property (nonatomic, strong) IBOutlet UILabel *exerciseType;
@property (nonatomic, strong) IBOutlet UIView *separator;
@property (nonatomic, strong) IBOutlet UILabel *exerciseMuscle;
@property (nonatomic, strong) IBOutlet UILabel *exerciseEquipment;
@property (nonatomic, strong) IBOutlet UILabel *exerciseLevel;


@end
