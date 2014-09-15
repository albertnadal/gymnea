//
//  WorkoutPlayTableViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 28/08/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutPlayTableViewController.h"
#import "WorkoutPlayTableViewCell.h"
#import "WorkoutDayExercise+Management.h"
#import "Exercise+Management.h"
#import "ExerciseDetail+Management.h"
#import "GymneaWSClient.h"

@interface WorkoutPlayTableViewController ()
{
    NSArray *exercises;
}

@property (nonatomic, strong) NSArray *exercises;

@end

@implementation WorkoutPlayTableViewController

@synthesize exercises;

- (id)initWithExercises:(NSSet *)theExercises
{
    if(self = [super initWithNibName:@"WorkoutPlayTableViewController" bundle:nil])
    {
        // Sort exercises by the order key
        NSMutableSet *exercisesMutableSet = [[NSMutableSet alloc] initWithSet:theExercises];
        NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        self.exercises = [exercisesMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:orderDescriptor]];

        return self;
    }

    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"WorkoutPlayTableViewCell" bundle:nil] forCellReuseIdentifier:@"GEAPlayWorkoutDayExercises"];
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.exercises count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 168.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkoutPlayTableViewCell *cell = (WorkoutPlayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GEAPlayWorkoutDayExercises"];

    WorkoutDayExercise *workoutDayExercise = (WorkoutDayExercise *)[self.exercises objectAtIndex:indexPath.row];

    if([[(WorkoutPlayTableViewCell *)cell exerciseTitleLabel] tag] != 1234)
    {
        [[(WorkoutPlayTableViewCell *)cell exerciseTitleLabel] setTag:1234];
        UIBezierPath *pictureViewShadowPath = [UIBezierPath bezierPathWithRect:[(WorkoutPlayTableViewCell *)cell pictureContainer].frame];
        [(WorkoutPlayTableViewCell *)cell pictureContainer].layer.shadowPath = pictureViewShadowPath.CGPath;
        [(WorkoutPlayTableViewCell *)cell pictureContainer].layer.cornerRadius = [(WorkoutPlayTableViewCell *)cell pictureContainer].frame.size.width / 2.0f;;
        [(WorkoutPlayTableViewCell *)cell pictureContainer].layer.masksToBounds = YES;

        UIBezierPath *restViewShadowPath = [UIBezierPath bezierPathWithRect:[(WorkoutPlayTableViewCell *)cell restContainer].frame];
        [(WorkoutPlayTableViewCell *)cell restContainer].layer.shadowPath = restViewShadowPath.CGPath;
        [(WorkoutPlayTableViewCell *)cell restContainer].layer.cornerRadius = [(WorkoutPlayTableViewCell *)cell restContainer].frame.size.width / 2.0f;;
        [(WorkoutPlayTableViewCell *)cell restContainer].layer.masksToBounds = YES;
    }

    [[(WorkoutPlayTableViewCell *)cell exerciseTitleLabel] setText:workoutDayExercise.name];
    [[(WorkoutPlayTableViewCell *)cell exerciseRepsLabel] setText:[NSString stringWithFormat:@"%@ Reps.", workoutDayExercise.reps]];
    [[(WorkoutPlayTableViewCell *)cell exerciseSetsLabel] setText:[NSString stringWithFormat:@"%d sets", workoutDayExercise.sets]];
    [[(WorkoutPlayTableViewCell *)cell exerciseRestLabel] setText:[NSString stringWithFormat:@"%d\"", workoutDayExercise.time]];

    [[(WorkoutPlayTableViewCell *)cell firstConnector] setHidden:!indexPath.row];
    [[(WorkoutPlayTableViewCell *)cell lastConnector] setHidden:(indexPath.row == [self.exercises count] - 1)];

    [[GymneaWSClient sharedInstance] requestImageForExercise:workoutDayExercise.exerciseId
                                                    withSize:ExerciseImageSizeMedium
                                                  withGender:ExerciseImageMale
                                                   withOrder:ExerciseImageFirst
                                         withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *exerciseImage, int exerciseId) {
                                             
                                             if(success==GymneaWSClientRequestSuccess) {
                                                 
                                                 if(exerciseImage == nil) {
                                                     exerciseImage = [UIImage imageNamed:@"exercise-default-thumbnail"];
                                                 }
                                                 
                                                 [[(WorkoutPlayTableViewCell *)cell thumbnail] setImage:exerciseImage];
                                             }
                                             
                                         }];

    return cell;
}

@end
