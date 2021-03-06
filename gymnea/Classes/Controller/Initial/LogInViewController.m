//
//  LogInViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "LogInViewController.h"
#import "StartViewController.h"
#import "MBProgressHUD.h"
#import "GymneaWSClient.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface LogInViewController ()

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
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

    self.screenName = @"LogInView";

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                        action:@"LogIn"
                                                                                         label:@"viewDidLoad"
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameTextField) {
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if(textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        GymneaWSClient *gymneaWSClient = [GymneaWSClient sharedInstance];
        [gymneaWSClient signInForUsername:[self.usernameTextField text]
                              andPassword:[self.passwordTextField text]
                      withCompletionBlock:^(GymneaSignInWSClientRequestResponse success, NSDictionary *responseData, UserInfo *userInfo) {

                      [MBProgressHUD hideHUDForView:self.view animated:YES];

                      if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"false"]) {

                          [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                                              action:@"LogIn"
                                                                                                               label:@"LogIn Failed"
                                                                                                               value:nil] build]];
                          [[GAI sharedInstance] dispatch];

                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseData objectForKey:@"errorMsg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                          [alert show];

                      } else if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"true"]){

                          [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                                              action:@"LogIn"
                                                                                                               label:@"LogIn Success"
                                                                                                               value:nil] build]];
                          [[GAI sharedInstance] dispatch];

                          StartViewController *startViewController = [[StartViewController alloc] initShowingSplashScreen:NO];
                          [self.navigationController pushViewController:startViewController animated:NO];

                      } else {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                          [alert show];
                      }

                  }];
    }

    return TRUE;
}

@end
