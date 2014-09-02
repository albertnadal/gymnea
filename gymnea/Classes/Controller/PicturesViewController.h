//
//  PicturesViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 01/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "GymneaWSClient.h"
#import "UserPicture+Management.h"
#import "MWPhotoBrowser/MWPhotoBrowser.h"

@interface PicturesViewController : MWPhotoBrowser

@property (nonatomic, retain) MBProgressHUD *loadPicturesHud;
@property (nonatomic, weak) IBOutlet UILabel *noPicturesFoundLabel;

- (id)init;
- (void)loadPicturesFromArray:(NSArray *)picList;
- (void)loadInitialData;

@end
