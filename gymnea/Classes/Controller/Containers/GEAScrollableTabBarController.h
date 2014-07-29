//
//  GEAScrollableTabBarController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 29/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Container view controller that shows a scrollable tab bar on top of the screen similar to the one seen on the Groupon app
 */
@interface GEAScrollableTabBarController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;

@end
