//
//  EditProfileViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 14/09/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

- (IBAction)cancelEditProfile:(id)sender;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)cancelEditProfile:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
