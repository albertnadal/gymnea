//
//  SignUpViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpForm.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate>

- (id)initWithSignUpForm:(SignUpForm *)theSignUpForm;

@end
