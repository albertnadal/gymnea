//
//  InitialViewController.m
//  gymnea
//
//  Created by Albert Nadal Garriga on 06/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "InitialViewController.h"
#import "InitialQuestionnaireViewController.h"
#import "LogInViewController.h"

@interface InitialViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *rightGradientLine;
@property (nonatomic, weak) IBOutlet UIImageView *leftGradientLine;
@property (nonatomic, weak) IBOutlet UIButton *getStartedButton;
@property (nonatomic, weak) IBOutlet UIButton *logInButton;
@property (nonatomic, weak) IBOutlet UIButton *goDownButton;
@property (nonatomic, weak) IBOutlet UIButton *okayButton;
@property (nonatomic, weak) IBOutlet UIView *getStartedView;
@property (nonatomic, weak) IBOutlet UIView *beforeContinueView;

- (IBAction)goBackToStartedView:(id)sender;

@end

@implementation InitialViewController

- (id)init
{
    self = [super initWithNibName:@"InitialViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.beforeContinueView];
    CGRect beforeContinueViewRect = self.beforeContinueView.frame;
    beforeContinueViewRect.origin.y = 0.0f - [[UIScreen mainScreen] bounds].size.height;
    self.beforeContinueView.frame = beforeContinueViewRect;

    [self.view addSubview:self.getStartedView];

    [self.getStartedButton addTarget:self action:@selector(getStarted:) forControlEvents:UIControlEventTouchUpInside];
    [self.getStartedButton addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
    [self.getStartedButton addTarget:self action:@selector(clearBgColorForButton:) forControlEvents:UIControlEventTouchDragExit];

    [self.logInButton addTarget:self action:@selector(logIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.logInButton addTarget:self action:@selector(setBgColorForLogInButton:) forControlEvents:UIControlEventTouchDown];
    [self.logInButton addTarget:self action:@selector(clearBgColorForLogInButton:) forControlEvents:UIControlEventTouchDragExit];

    [self.okayButton addTarget:self action:@selector(goToQuestionnaire:) forControlEvents:UIControlEventTouchUpInside];
    [self.okayButton addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
    [self.okayButton addTarget:self action:@selector(clearBgColorForButton:) forControlEvents:UIControlEventTouchDragExit];

    [UIView animateWithDuration:0.9
                          delay:0.9
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{

                         CGRect leftGradientLineRect = self.leftGradientLine.frame;
                         leftGradientLineRect.origin.x = 0.0f - CGRectGetMaxX(leftGradientLineRect);
                         self.leftGradientLine.frame = leftGradientLineRect;

                         CGRect screenRect = [[UIScreen mainScreen] bounds];
                         CGFloat screenWidth = screenRect.size.width;

                         CGRect rightGradientLineRect = self.rightGradientLine.frame;
                         rightGradientLineRect.origin.x = screenWidth + 1.0f;
                         self.rightGradientLine.frame = rightGradientLineRect;

    } completion:^(BOOL finished) {

    }];

}

- (IBAction)goToQuestionnaire:(id)sender
{
    [self clearBgColorForButton:sender];

    InitialQuestionnaireViewController *initialQuestionnaireViewController = [[InitialQuestionnaireViewController alloc] init];
    [self.navigationController pushViewController:initialQuestionnaireViewController animated:YES];
}

- (IBAction)goBackToStartedView:(id)sender
{
    [UIView animateWithDuration: 0.3
                     animations:^{

                         CGRect getStartedViewRect = self.getStartedView.frame;
                         getStartedViewRect.origin.y = 0.0f;
                         self.getStartedView.frame = getStartedViewRect;

                         CGRect beforeContinueViewRect = self.beforeContinueView.frame;
                         beforeContinueViewRect.origin.y = 0.0f - [[UIScreen mainScreen] bounds].size.height;
                         self.beforeContinueView.frame = beforeContinueViewRect;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)logIn:(UIButton*)sender
{
    [self clearBgColorForLogInButton:sender];

    LogInViewController *logInViewController = [[LogInViewController alloc] init];
    [self.navigationController pushViewController:logInViewController animated:YES];
}

-(void)setBgColorForLogInButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:0.7] forState:UIControlStateNormal];
}

-(void)clearBgColorForLogInButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:1] forState:UIControlStateNormal];
}

-(void)getStarted:(UIButton*)sender
{
    [self clearBgColorForButton:sender];

    [UIView animateWithDuration: 0.3
                     animations:^{

                         CGRect beforeContinueViewRect = self.beforeContinueView.frame;
                         beforeContinueViewRect.origin.y = 0.0;
                         self.beforeContinueView.frame = beforeContinueViewRect;

                         CGRect getStartedViewRect = self.getStartedView.frame;
                         getStartedViewRect.origin.y = [[UIScreen mainScreen] bounds].size.height + 1.0f;
                         self.getStartedView.frame = getStartedViewRect;

                     } completion:^(BOOL finished) {

                     }];
}

-(void)setBgColorForButton:(UIButton*)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:0.7]];
}

-(void)clearBgColorForButton:(UIButton*)sender
{
    [sender setBackgroundColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:1]];
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
