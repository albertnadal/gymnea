//
//  InitialQuestionnaireGoalViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "InitialQuestionnaireGoalViewController.h"
#import "SignUpViewController.h"

@interface InitialQuestionnaireGoalViewController ()

@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *getLeanButton;
@property (nonatomic, weak) IBOutlet UIButton *burnFatButton;
@property (nonatomic, weak) IBOutlet UIButton *muscleBuildingButton;
@property (nonatomic, weak) IBOutlet UIButton *increaseStrengthButton;
@property (nonatomic, retain) SignUpInForm *signUpForm;

- (IBAction)goBack:(id)sender;
- (IBAction)selectOptionButton:(id)button;

@end

@implementation InitialQuestionnaireGoalViewController

- (id)initWithSignUpForm:(SignUpInForm *)theSignUpForm
{
    self = [super initWithNibName:@"InitialQuestionnaireGoalViewController" bundle:nil];
    if (self)
    {
        self.signUpForm = theSignUpForm;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.nextButton addTarget:self action:@selector(goToRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
    [self.nextButton addTarget:self action:@selector(clearBgColorForButton:) forControlEvents:UIControlEventTouchDragExit];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectOptionButton:(id)button
{
    [self.getLeanButton setSelected:NO];
    [self.burnFatButton setSelected:NO];
    [self.muscleBuildingButton setSelected:NO];
    [self.increaseStrengthButton setSelected:NO];

    [button setSelected:YES];
    
    switch ([button tag]) {
        case 1:     [self.signUpForm setFitnessGoal:FitnessGoalAnswerGetLean];
                    break;
            
        case 2:     [self.signUpForm setFitnessGoal:FitnessGoalAnswerBurnFat];
                    break;
            
        case 3:     [self.signUpForm setFitnessGoal:FitnessGoalAnswerMuscleBuilding];
                    break;
            
        case 4:     [self.signUpForm setFitnessGoal:FitnessGoalAnswerIncreaseStrength];
                    break;

        default:
                    break;
    }
}

- (void)goToRegister:(id)sender
{
    [self clearBgColorForButton:sender];

    SignUpViewController *signUpViewController = [[SignUpViewController alloc] initWithSignUpForm:self.signUpForm];
    [self.navigationController pushViewController:signUpViewController animated:YES];
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
