//
//  EditProfileViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 14/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface EditProfileViewController : GAITrackedViewController<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end
