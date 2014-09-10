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

@interface NextExerciseCountdownViewController ()<UIActionSheetDelegate>
{
    int countdownSeconds;
    BOOL countdownActive;
}

@property (strong, retain) NSDate *initialDate;
@property (nonatomic, weak) IBOutlet UILabel *countdownLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *exerciseSetsAndRepetitionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UIView *buttonsView;
@property (nonatomic, retain) NSTimer *countdownTemporizer;
@property (assign) SystemSoundID countdownSound;

- (void)updateTimer:(id)sender;
- (IBAction)forceFinishCountdown:(id)sender;
- (IBAction)showOptionsMenu:(id)sender;

@end

@implementation NextExerciseCountdownViewController

- (id)initWithDelegate:(id<NextExerciseCountdownViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"NextExerciseCountdownViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        self.countdownTemporizer = nil;
        countdownSeconds = 10;
        countdownActive = TRUE;
        self.initialDate = nil;
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

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Get ready!" fontSize:21.0f frame:CGRectMake(0.0f,20.0f,[[UIScreen mainScreen] bounds].size.width,44.0f)];
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

    self.initialDate = [NSDate date];
}

- (void)updateTimer:(id)sender
{
    if(!countdownActive)
        return;

    [self.countdownLabel setText:[NSString stringWithFormat:@"%d", countdownSeconds]];

    if((countdownSeconds<=3) && (countdownSeconds>0)) {
        AudioServicesPlaySystemSound(self.countdownSound);
    }

    if(countdownSeconds<=0) {
        [self.countdownTemporizer invalidate];
        self.countdownTemporizer = nil;

        if([self.delegate respondsToSelector:@selector(totalSecondsResting:withSeconds:)])
            [self.delegate totalSecondsResting:self withSeconds:[[NSDate date] timeIntervalSinceDate:self.initialDate]];

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

- (IBAction)showOptionsMenu:(id)sender
{
    countdownActive = FALSE;
    
    UIActionSheet *popupOptions = [[UIActionSheet alloc] initWithTitle:@"Don't stop now!" delegate:self cancelButtonTitle:@"Resume" destructiveButtonTitle:@"End Workout" otherButtonTitles: nil];
    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
    [popupOptions showInView:self.view];
}

- (IBAction)forceFinishCountdown:(id)sender
{
    [self.countdownTemporizer invalidate];
    self.countdownTemporizer = nil;

    if([self.delegate respondsToSelector:@selector(totalSecondsResting:withSeconds:)])
        [self.delegate totalSecondsResting:self withSeconds:[[NSDate date] timeIntervalSinceDate:self.initialDate]];

    if([self.delegate respondsToSelector:@selector(nextExerciseCountdownFinished:)])
        [self.delegate nextExerciseCountdownFinished:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.countdownTemporizer invalidate];
        self.countdownTemporizer = nil;

        if([self.delegate respondsToSelector:@selector(userDidSelectFinishWorkoutFromCountdown:)])
        {
            [self.delegate userDidSelectFinishWorkoutFromCountdown:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else if (buttonIndex == 1) {
        countdownActive = TRUE;
    }
}

@end
