//
//  InitialQuestionnaireViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 07/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "InitialQuestionnaireViewController.h"
#import "InitialQuestionnaireGoalViewController.h"

@interface InitialQuestionnaireViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *scrollContainerView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *skipButton;

- (IBAction)goBack:(id)sender;


@end

@implementation InitialQuestionnaireViewController

- (id)init
{
    self = [super initWithNibName:@"InitialQuestionnaireViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    [self.skipButton addTarget:self action:@selector(setBgColorForSkipButton:) forControlEvents:UIControlEventTouchDown];
    [self.skipButton addTarget:self action:@selector(clearBgColorForSkipButton:) forControlEvents:UIControlEventTouchDragExit];

    [self.scrollView addSubview:self.scrollContainerView];
    [self.scrollView setContentSize:CGSizeMake(self.scrollContainerView.frame.size.width, self.scrollContainerView.frame.size.height)];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)skip:(id)sender
{
    [self clearBgColorForSkipButton:sender];

    InitialQuestionnaireGoalViewController *initialQuestionnaireGoalViewController = [[InitialQuestionnaireGoalViewController alloc] init];
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
