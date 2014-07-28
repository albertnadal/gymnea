//
//  WorkoutPlayRestViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayRestViewController.h"
#import "GEALabel+Gymnea.h"

@interface WorkoutPlayRestViewController ()<UIActionSheetDelegate>
{
    int countdownSeconds;
    BOOL countdownActive;
}

@property (nonatomic, weak) IBOutlet UILabel *countdownLabel;
@property (nonatomic, retain) NSTimer *countdownTemporizer;

- (void)updateTimer:(id)sender;
- (IBAction)exerciseRestFinished:(id)sender;
- (IBAction)showOptionsMenu:(id)sender;

@end

@implementation WorkoutPlayRestViewController

- (id)initWithDelegate:(id<WorkoutPlayRestViewControllerDelegate>)delegate_
{
    self = [super initWithNibName:@"WorkoutPlayRestViewController" bundle:nil];
    if (self) {
        self.delegate = delegate_;
        self.countdownTemporizer = nil;
        countdownActive = TRUE;
        countdownSeconds = 60;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GEALabel *titleModal = [[GEALabel alloc] initWithText:@"Take a breath" fontSize:21.0f frame:CGRectMake(10.0f,20.0f,[[UIScreen mainScreen] bounds].size.width - 20.0f,44.0f)];
    [self.view addSubview:titleModal];

    [self.countdownLabel setText:[NSString stringWithFormat:@"%d", countdownSeconds]];
    
    self.countdownTemporizer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                target:self
                                                              selector:@selector(updateTimer:)
                                                              userInfo:nil
                                                               repeats:YES];
}

- (void)updateTimer:(id)sender
{
    if(!countdownActive)
        return;

    countdownSeconds--;
    [self.countdownLabel setText:[NSString stringWithFormat:@"%d", countdownSeconds]];
    
    if(countdownSeconds<=0) {
        [self.countdownTemporizer invalidate];
        self.countdownTemporizer = nil;
        
        if([self.delegate respondsToSelector:@selector(workoutExerciseRestFinished:)])
            [self.delegate workoutExerciseRestFinished:self];
    }
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

- (IBAction)exerciseRestFinished:(id)sender
{
    [self.countdownTemporizer invalidate];
    self.countdownTemporizer = nil;

    if([self.delegate respondsToSelector:@selector(workoutExerciseRestFinished:)])
        [self.delegate workoutExerciseRestFinished:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.countdownTemporizer invalidate];
        self.countdownTemporizer = nil;
    } else if (buttonIndex == 1) {
        countdownActive = TRUE;
    }
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