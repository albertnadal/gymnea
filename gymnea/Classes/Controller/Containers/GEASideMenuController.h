//
//  GEASideMenuController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Container view controller similar to the side menu seen in other apps like facebook, path, foursquare...
 */
@interface GEASideMenuController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic) BOOL sideMenuHidden;

- (void)setSideMenuHidden:(BOOL)hidden
                 animated:(BOOL)animated;

@end

/**
 UIViewController category that provides direct access to the container side menu controller from any child view controller
 */
@interface UIViewController (GEASideMenuController)

@property (nonatomic, weak) GEASideMenuController *sideMenuController;

@end
