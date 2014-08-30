//
//  NextExerciseCountdownViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "NextExerciseCountdownViewController.h"
#import "GymneaWSClient.h"
#import "GEALabel+Gymnea.h"

@import AVFoundation;

@interface NextExerciseCountdownViewController ()
{
    int countdownSeconds;
}

@property (nonatomic, weak) IBOutlet UILabel *countdownLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseSetsAndRepetitionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, retain) NSTimer *countdownTemporizer;
@property (assign) SystemSoundID countdownSound;

- (void)updateTimer:(id)sender;

@end

@implementation NextExerciseCountdownViewController

- (id)initWithDelegate:(id<NextExerciseCountdownViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"NextExerciseCountdownViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        self.countdownTemporizer = nil;
        countdownSeconds = 10;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = TRUE;

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Get ready!" fontSize:18.0f frame:CGRectMake(0.0f,20.0f,[[UIScreen mainScreen] bounds].size.width,44.0f)];
    [self.view addSubview:titleModal];

    NSString *pewPewPath = [[NSBundle mainBundle] pathForResource:@"clock_tic" ofType:@"wav"];
    NSURL *pewPewURL = [NSURL fileURLWithPath:pewPewPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &_countdownSound);

    UIBezierPath *pictureViewShadowPath = [UIBezierPath bezierPathWithRect:self.thumbnail.frame];
    self.thumbnail.layer.shadowPath = pictureViewShadowPath.CGPath;
    self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2.0f;;
    self.thumbnail.layer.masksToBounds = YES;

    if([self.delegate respondsToSelector:@selector(nextExerciseId:)]) {
        int exerciseId = [self.delegate nextExerciseId:self];

        [[GymneaWSClient sharedInstance] requestImageForExercise:exerciseId
                                                        withSize:ExerciseImageSizeMedium withGender:ExerciseImageMale
                                                       withOrder:ExerciseImageFirst
                                             withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *exerciseImage) {
                                                 [self.thumbnail setImage:exerciseImage];
                                             }];
    }

    NSString *setsAndRepetitions = @"";

    if([self.delegate respondsToSelector:@selector(nextExerciseTotalRepetitions:)])
        setsAndRepetitions = [NSString stringWithFormat:@"%ld sets", (long)[self.delegate nextExerciseTotalRepetitions:self]];

    if([self.delegate respondsToSelector:@selector(nextExerciseSetsRepetitionsString:)])
        setsAndRepetitions = [setsAndRepetitions stringByAppendingFormat:@"\n%@ Reps.", [self.delegate nextExerciseSetsRepetitionsString:self]];

    [self.exerciseSetsAndRepetitionsLabel setText:setsAndRepetitions];

    if([self.delegate respondsToSelector:@selector(nextExerciseName:)])
        [self.exerciseTitleLabel setText:[self.delegate nextExerciseName:self]];

    if([self.delegate respondsToSelector:@selector(numberOfSecondsToCoundown:)])
        countdownSeconds = (int)[self.delegate numberOfSecondsToCoundown:self];

    [self.countdownLabel setText:[NSString stringWithFormat:@"%d", countdownSeconds]];

    self.countdownTemporizer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                target:self
                                                              selector:@selector(updateTimer:)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void)updateTimer:(id)sender
{
    [self.countdownLabel setText:[NSString stringWithFormat:@"%d", countdownSeconds]];

    if((countdownSeconds<=3) && (countdownSeconds>0)) {
        AudioServicesPlaySystemSound(self.countdownSound);
    }

    if(countdownSeconds<=0) {
        [self.countdownTemporizer invalidate];
        self.countdownTemporizer = nil;

        if([self.delegate respondsToSelector:@selector(nextExerciseCountdownFinished:)])
            [self.delegate nextExerciseCountdownFinished:self];
    }

    countdownSeconds--;
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
