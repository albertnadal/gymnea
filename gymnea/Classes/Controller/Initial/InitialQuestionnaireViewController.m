//
//  InitialQuestionnaireViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 07/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "InitialQuestionnaireViewController.h"
#import "InitialQuestionnaireGoalViewController.h"
#import "SignUpForm.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@interface InitialQuestionnaireViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *scrollContainerView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;
@property (nonatomic, retain) SignUpForm *signUpForm;

- (IBAction)goBack:(id)sender;
- (void)goToQuestionnaireGoal;

@end

@implementation InitialQuestionnaireViewController

- (id)init
{
    self = [super initWithNibName:@"InitialQuestionnaireViewController" bundle:nil];
    if (self)
    {
        self.signUpForm = [[SignUpForm alloc] initWithName:@""
                                                  lastName:@""
                                              emailAddress:@""
                                                  password:@""
                                                    gender:@""
                                                       day:0
                                                     month:0
                                                    weight:0
                                                    weight:0.0f
                                            weightIsMetric:NO
                                               centimeters:0
                                                      foot:0
                                                    inches:0
                                                    height:0
                                            heightIsMetric:NO
                                         wearTrackerAnswer:QuestionaireAnswerUnknown
                                             goToGymAnswer:QuestionaireAnswerUnknown
                                                  useVideo:QuestionaireAnswerUnknown
                                               fitnessGoal:FitnessGoalAnswerNoGoal];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = @"InitialQuestionnaireView";

    [self.skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    [self.skipButton addTarget:self action:@selector(setBgColorForSkipButton:) forControlEvents:UIControlEventTouchDown];
    [self.skipButton addTarget:self action:@selector(clearBgColorForSkipButton:) forControlEvents:UIControlEventTouchDragExit];

    [self.scrollView addSubview:self.scrollContainerView];
    [self.scrollView setContentSize:CGSizeMake(self.scrollContainerView.frame.size.width, self.scrollContainerView.frame.size.height)];

    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Initial"
                                                                                        action:@"Questionnaire"
                                                                                         label:@"viewDidLoad"
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectOptionButton:(id)button
{
    [button setSelected:![button isSelected]];

    switch ([button tag]) {
        case 1:     [(UIButton *)[self.scrollContainerView viewWithTag:2] setSelected:NO];
                    [self.signUpForm setDoYouWearActivityTracker:QuestionaireAnswerNO];
                    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 1, 0.0f) animated:YES];
                    break;

        case 2:     [(UIButton *)[self.scrollContainerView viewWithTag:1] setSelected:NO];
                    [self.signUpForm setDoYouWearActivityTracker:QuestionaireAnswerYes];
                    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 1, 0.0f) animated:YES];
                    break;

        case 3:     [(UIButton *)[self.scrollContainerView viewWithTag:4] setSelected:NO];
                    [self.signUpForm setDoYouGoToGym:QuestionaireAnswerNO];
                    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, 0.0f) animated:YES];
                    break;
            
        case 4:     [(UIButton *)[self.scrollContainerView viewWithTag:3] setSelected:NO];
                    [self.signUpForm setDoYouGoToGym:QuestionaireAnswerYes];
                    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, 0.0f) animated:YES];
                    break;

        case 5:     [(UIButton *)[self.scrollContainerView viewWithTag:6] setSelected:NO];
                    [self.signUpForm setAreYouFamiliarWithVideoconference:QuestionaireAnswerNO];
                    [self goToQuestionnaireGoal];
                    break;
            
        case 6:     [(UIButton *)[self.scrollContainerView viewWithTag:5] setSelected:NO];
                    [self.signUpForm setAreYouFamiliarWithVideoconference:QuestionaireAnswerYes];
                    [self goToQuestionnaireGoal];
                    break;

        default:
            break;
    }
}

- (void)skip:(id)sender
{
    [self clearBgColorForSkipButton:sender];
    [self goToQuestionnaireGoal];
}

- (void)goToQuestionnaireGoal
{
    InitialQuestionnaireGoalViewController *initialQuestionnaireGoalViewController = [[InitialQuestionnaireGoalViewController alloc] initWithSignUpForm:self.signUpForm];
    [self.navigationController pushViewController:initialQuestionnaireGoalViewController animated:YES];
}

-(void)setBgColorForSkipButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:0.7] forState:UIControlStateNormal];
}

-(void)clearBgColorForSkipButton:(UIButton*)sender
{
    [sender setTitleColor:[UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:1] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = lround(fractionalPage);
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
