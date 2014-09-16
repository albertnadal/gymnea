//
//  StartViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface StartViewController : GAITrackedViewController<UIAlertViewDelegate>

- (id)initShowingSplashScreen:(BOOL)showSplash;

@end
