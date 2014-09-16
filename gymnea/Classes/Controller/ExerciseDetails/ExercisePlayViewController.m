//
//  ExercisePlayViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 19/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExercisePlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GEALabel+Gymnea.h"

@interface ExercisePlayViewController ()<UIActionSheetDelegate>
{
    Exercise *exercise;
    ExerciseDetail *exerciseDetails;
    IBOutlet UILabel *timeCounterLabel;
    int counterSeconds;
    BOOL counterActive;
}

@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) ExerciseDetail *exerciseDetails;
@property (nonatomic, retain) NSURL *videoFileURL;
@property (nonatomic, retain) IBOutlet UILabel *timeCounterLabel;
@property (nonatomic, retain) NSTimer *timeCounter;

- (IBAction)showOptionsMenu:(id)sender;
- (void)updateTimer:(id)sender;

@end

@implementation ExercisePlayViewController

@synthesize exercise;
@synthesize exerciseDetails;
@synthesize timeCounterLabel;

- (id)initWithExercise:(Exercise *)exercise_ withDetails:(ExerciseDetail *)details_ withDelegate:(id<ExercisePlayViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"ExercisePlayViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        self.exercise = exercise_;
        self.exerciseDetails = details_;
        self.videoFileURL = nil;
        self.timeCounter = nil;
        counterSeconds = 0;
        counterActive = TRUE;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = TRUE;

    [self.timeCounterLabel setText:[NSString stringWithFormat:@"%d\"", counterSeconds]];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:[self.exercise name] fontSize:21.0f frame:CGRectMake(10.0f,20.0f,[[UIScreen mainScreen] bounds].size.width - 20.0f,44.0f)];
    [self.view addSubview:titleModal];

    NSError *error = nil;

    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];

    self.videoFileURL = [directoryURL URLByAppendingPathComponent:@"loop.mp4"];

    [(NSData *)self.exerciseDetails.videoLoop writeToURL:self.videoFileURL options:NSDataWritingAtomic error:&error];

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

    self.timeCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(updateTimer:)
                                                      userInfo:nil
                                                       repeats:YES];

}

- (void)updateTimer:(id)sender
{
    if((!self.timeCounter) || (!counterActive))
        return;

    [self.timeCounterLabel setText:[NSString stringWithFormat:@"%d\"", counterSeconds]];

    counterSeconds++;
}

- (void)videoReplay:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [player play];
}

- (IBAction)showOptionsMenu:(id)sender
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ExercisePlay"
                                                                                        action:@"Show Options Menu"
                                                                                         label:@""
                                                                                         value:nil] build]];
    [[GAI sharedInstance] dispatch];

    counterActive = FALSE;
    [_videoPlayer pause];

    UIActionSheet *popupOptions = [[UIActionSheet alloc] initWithTitle:@"Don't stop now!" delegate:self cancelButtonTitle:@"Resume" destructiveButtonTitle:@"End Exercise" otherButtonTitles: nil];
    popupOptions.actionSheetStyle = UIActionSheetStyleDefault;
    [popupOptions showInView:self.view];
}

- (IBAction)exerciseFinished:(id)sender
{
    if([self.delegate respondsToSelector:@selector(exerciseFinished:)])
    {
        [self.timeCounter invalidate];
        self.timeCounter = nil;

        // Delete the temporal file used to play the video
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.videoFileURL error:&error];

        [self.delegate exerciseFinished:self];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ExercisePlay"
                                                                                            action:@"Finish Play Exercise"
                                                                                             label:@""
                                                                                             value:nil] build]];
        [[GAI sharedInstance] dispatch];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_videoPlayer];
        [_videoPlayer stop];

        if([self.delegate respondsToSelector:@selector(userDidSelectFinishExercise:)]) {

            [self.timeCounter invalidate];
            self.timeCounter = nil;

            // Delete the temporal file used to play the video
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtURL:self.videoFileURL error:&error];

            [self.delegate userDidSelectFinishExercise:self];
        }

    } else if (buttonIndex == 1) {

        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ExercisePlay"
                                                                                            action:@"Resume Play Exercise"
                                                                                             label:@""
                                                                                             value:nil] build]];
        [[GAI sharedInstance] dispatch];

        counterActive = TRUE;
        [_videoPlayer play];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"ExercisePlayViewController";
}

@end
