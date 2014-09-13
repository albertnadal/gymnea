//
//  WorkoutPlayResultsViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 31/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayResultsViewController.h"
#import "GEASideMenuController.h"
#import "GymneaWSClient.h"
#import "GEALabel+Gymnea.h"

@interface WorkoutPlayResultsViewController ()
{
    int totalExerciseSeconds;
    int totalRestSeconds;
}

@property (nonatomic, weak) IBOutlet UILabel *workoutTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *workoutDayTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *restTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UIView *buttonsView;

- (IBAction)discardResults:(id)sender;
- (IBAction)saveResults:(id)sender;

@end

@implementation WorkoutPlayResultsViewController

- (id)initWithDelegate:(id<WorkoutPlayResultsViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"WorkoutPlayResultsViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        totalExerciseSeconds = 0;
        totalRestSeconds = 0;
    }

    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect buttonsViewFrame = self.buttonsView.frame;
    buttonsViewFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - CGRectGetHeight(buttonsViewFrame);
    self.buttonsView.frame = buttonsViewFrame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = TRUE;

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Training results" fontSize:21.0f frame:CGRectMake(0.0f,20.0f,[[UIScreen mainScreen] bounds].size.width,44.0f)];
    [self.view addSubview:titleModal];

    UIBezierPath *pictureViewShadowPath = [UIBezierPath bezierPathWithRect:self.thumbnail.frame];
    self.thumbnail.layer.shadowPath = pictureViewShadowPath.CGPath;
    self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2.0f;;
    self.thumbnail.layer.masksToBounds = YES;

    if([self.delegate respondsToSelector:@selector(getGetTotalPlayedExerciseSeconds:)]) {
        totalExerciseSeconds = [self.delegate getGetTotalPlayedExerciseSeconds:self];
        [self.exerciseTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d", (totalExerciseSeconds / 60) % 60, totalExerciseSeconds % 60]];
    }

    if([self.delegate respondsToSelector:@selector(getGetTotalRestSeconds:)]) {
        totalRestSeconds = [self.delegate getGetTotalRestSeconds:self];
        [self.restTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d", (totalRestSeconds / 60) % 60, totalRestSeconds % 60]];
    }

    [self.totalTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d", ((totalExerciseSeconds + totalRestSeconds) / 60) % 60, (totalExerciseSeconds + totalRestSeconds) % 60]];


    if([self.delegate respondsToSelector:@selector(getWorkoutDay:)]) {
        WorkoutDay *workoutDay = [self.delegate getWorkoutDay:self];
        int workoutId = workoutDay.workout.workoutId;

        [[GymneaWSClient sharedInstance] requestImageForWorkout:workoutId
                                                       withSize:WorkoutImageSizeMedium
                                            withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *workoutImage) {
                                                [self.thumbnail setImage:workoutImage];
                                            }];

        [self.workoutTitleLabel setText:[[Workout getWorkoutInfo:workoutId] name]];
        [self.workoutDayTitleLabel setText:workoutDay.title];
    }

}

- (IBAction)discardResults:(id)sender
{
    
    if([self.delegate respondsToSelector:@selector(userDidSelectDiscardResults:)])
        [self.delegate userDidSelectDiscardResults:self];

    WorkoutDetailViewController *lastWorkoutDetailViewController = nil;
    for(UIViewController *viewController in [self.navigationController viewControllers]) {
        if([viewController isKindOfClass:[WorkoutDetailViewController class]]) {
            lastWorkoutDetailViewController = (WorkoutDetailViewController *)viewController;
        }
    }
    
    self.navigationController.navigationBar.hidden = FALSE;
    
    if(lastWorkoutDetailViewController == nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:lastWorkoutDetailViewController animated:YES];
    }
}

- (IBAction)saveResults:(id)sender
{
    if([self.delegate respondsToSelector:@selector(userDidSelectSaveResults:)])
        [self.delegate userDidSelectSaveResults:self];

    WorkoutDetailViewController *lastWorkoutDetailViewController = nil;
    for(UIViewController *viewController in [self.navigationController viewControllers]) {
        if([viewController isKindOfClass:[WorkoutDetailViewController class]]) {
            lastWorkoutDetailViewController = (WorkoutDetailViewController *)viewController;
        }
    }
    
    self.navigationController.navigationBar.hidden = FALSE;
    
    if(lastWorkoutDetailViewController == nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popToViewController:lastWorkoutDetailViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
