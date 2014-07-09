//
//  LogInViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "LogInViewController.h"
#import "StartViewController.h"

@interface LogInViewController ()

@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;

- (IBAction)goBack:(id)sender;

@end

@implementation LogInViewController

- (id)init
{
    self = [super initWithNibName:@"LogInViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.forgotPasswordButton addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton addTarget:self action:@selector(setBgColorForForgotPasswordButton:) forControlEvents:UIControlEventTouchDown];
    [self.forgotPasswordButton addTarget:self action:@selector(clearBgColorForForgotPasswordButton:) forControlEvents:UIControlEventTouchDragExit];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)forgotPassword:(UIButton*)sender
{
    [self clearBgColorForForgotPasswordButton:sender];
}

-(void)setBgColorForForgotPasswordButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:0.7] forState:UIControlStateNormal];
}

-(void)clearBgColorForForgotPasswordButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:1] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    StartViewController *startViewController = [[StartViewController alloc] init];
    [self.navigationController pushViewController:startViewController animated:NO];

    return TRUE;
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
