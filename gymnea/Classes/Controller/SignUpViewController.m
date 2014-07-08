//
//  SignUpViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

- (IBAction)goBack:(id)sender;

@end

@implementation SignUpViewController

- (id)init
{
    self = [super initWithNibName:@"SignUpViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
