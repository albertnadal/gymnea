//
//  WorkoutPlayExerciseViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayExerciseViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GEALabel+Gymnea.h"
#import "ExerciseDetail+Management.h"
#import "GymneaWSClient.h"

@interface WorkoutPlayExerciseViewController ()<UIActionSheetDelegate>

@property (nonatomic, retain) NSURL *videoFileURL;
@property (nonatomic, weak) IBOutlet UILabel *repetitionsLabel;
@property (nonatomic, weak) IBOutlet UILabel *setLabel;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;

- (IBAction)showOptionsMenu:(id)sender;

@end

@implementation WorkoutPlayExerciseViewController

- (id)initWithDelegate:(id<WorkoutPlayExerciseViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"WorkoutPlayExerciseViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        self.videoFileURL = nil;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = TRUE;

    if([self.delegate respondsToSelector:@selector(numberOfRepetitionsForCurrentExercise:)])
        [self.repetitionsLabel setText:[NSString stringWithFormat:@"%ld reps", (long)[self.delegate numberOfRepetitionsForCurrentExercise:self]]];

    NSString *currentExerciseName = @"";
    if([self.delegate respondsToSelector:@selector(currentExerciseName:)])
        currentExerciseName = [self.delegate currentExerciseName:self];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:currentExerciseName fontSize:21.0f frame:CGRectMake(10.0f,20.0f,[[UIScreen mainScreen] bounds].size.width - 20.0f,44.0f)];
    [self.view addSubview:titleModal];

    int totalSetsExercise = 1;
    int currentExerciseSet = 1;
    if([self.delegate respondsToSelector:@selector(numberOfSetsForCurrentExercise:)])
        totalSetsExercise = (int)[self.delegate numberOfSetsForCurrentExercise:self];

    if([self.delegate respondsToSelector:@selector(currentSetForCurrentExercise:)])
        currentExerciseSet = (int)[self.delegate currentSetForCurrentExercise:self];

    [self.setLabel setText:[NSString stringWithFormat:@"Set %d/%d", currentExerciseSet, totalSetsExercise]];



    if([self.delegate respondsToSelector:@selector(currentExerciseId:)])
    {
        int exerciseId = [self.delegate currentExerciseId:self];
        ExerciseDetail *exerciseDetails = [ExerciseDetail getExerciseDetailInfo:exerciseId];

        NSError *error = nil;

        NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
        [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];

        self.videoFileURL = [directoryURL URLByAppendingPathComponent:@"loop.mp4"];

        [(NSData *)exerciseDetails.videoLoop writeToURL:self.videoFileURL options:NSDataWritingAtomic error:&error];

        _videoPlayer =  [[MPMoviePlayerController alloc] initWithContentURL:self.videoFileURL];


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoReplay:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:_videoPlayer];

        _videoPlayer.controlStyle = MPMovieControlStyleNone;
        _videoPlayer.shouldAutoplay = YES;
        [_videoPlayer.view setFrame:CGRectMake(0, 65, 320, 178)];

        [self.view addSubview:_videoPlayer.view];
        [_videoPlayer setFullscreen:NO animated:NO];
    }
}

- (void)videoReplay:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [player play];

/*
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
*/
}

- (IBAction)showOptionsMenu:(id)sender
{
    [_videoPlayer pause];

    UIActionSheet *popupOptions = [[UIActionSheet alloc] initWithTitle:@"Don't stop now!" delegate:self cancelButtonTitle:@"Resume" destructiveButtonTitle:@"End Workout" otherButtonTitles: nil];
    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
    [popupOptions showInView:self.view];
}

- (IBAction)exerciseFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
    [_videoPlayer stop];

    // Delete the temporal file used to play the video
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.videoFileURL error:&error];

    if([self.delegate respondsToSelector:@selector(workoutExerciseFinished:)])
        [self.delegate workoutExerciseFinished:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
        [_videoPlayer stop];

        // Delete the temporal file used to play the video
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.videoFileURL error:&error];

        if([self.delegate respondsToSelector:@selector(userDidSelectFinishWorkoutFromExercise:)])
        {
            [self.delegate userDidSelectFinishWorkoutFromExercise:self];
            [self.navigationController popViewControllerAnimated:YES];
        }

    } else if (buttonIndex == 1) {
        [_videoPlayer play];
    }
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
