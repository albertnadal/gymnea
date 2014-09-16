//
//  InitialQuestionnaireViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 07/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface InitialQuestionnaireViewController : GAITrackedViewController<UIScrollViewDelegate>

- (id)init;
- (IBAction)selectOptionButton:(id)button;

@end
