//
//  WorkoutDayTableViewCell.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkoutDayTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *setsAndRepsLabel;
@property (nonatomic, weak) IBOutlet UILabel *restTimeLabel;

@end
