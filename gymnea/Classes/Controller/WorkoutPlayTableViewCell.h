//
//  WorkoutPlayTableViewCell.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutPlayTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UIView *pictureContainer;
@property (nonatomic, weak) IBOutlet UIView *restContainer;
@property (nonatomic, weak) IBOutlet UIView *firstConnector;
@property (nonatomic, weak) IBOutlet UIView *secondConnector;
@property (nonatomic, weak) IBOutlet UIView *lastConnector;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseRepsLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseSetsLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseRestLabel;

@end
