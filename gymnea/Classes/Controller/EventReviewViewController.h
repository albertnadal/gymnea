//
//  ReviewViewController.h
//  Vegas
//
//  Created by Albert Nadal Garriga on 11/04/13.
//  Copyright (c) 2013 Golden Gekko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventReview.h"

@interface EventReviewViewController : UIViewController

- (CGFloat)getHeight;
- (id)initWithEventReview:(EventReview *)review_;

@end
