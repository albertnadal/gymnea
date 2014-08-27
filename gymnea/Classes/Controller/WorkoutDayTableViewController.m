//
//  WorkoutDayTableViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 23/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDayTableViewController.h"
#import "WorkoutDayTableViewCell.h"
#import "WorkoutDay+Management.h"
#import "WorkoutDayExercise+Management.h"
#import "Exercise+Management.h"
#import "GymneaWSClient.h"

@interface WorkoutDayTableViewController ()
{
    // Id and model of the review to show
    NSArray *workoutDays;
}

@property (nonatomic, strong) NSArray *workoutDays;

@end


@implementation WorkoutDayTableViewController

@synthesize workoutDays;

- (id)initWithWorkoutDays:(NSSet *)workout_days_ withDelegate:(id<WorkoutDayTableViewControllerDelegate>)delegate_
{
    if(self = [super initWithNibName:@"WorkoutDayTableViewController" bundle:nil])
    {
        self.delegate = delegate_;

        // Sort workout days by day number {0..7}
        NSMutableSet *workoutDaysMutableSet = [[NSMutableSet alloc] initWithSet:workout_days_];
        NSSortDescriptor *dayNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dayNumber" ascending:YES];
        self.workoutDays = [workoutDaysMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:dayNumberDescriptor]];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"WorkoutDayTableViewCell" bundle:nil] forCellReuseIdentifier:@"GEAWorkoutDay"];
    self.clearsSelectionOnViewWillAppear = YES;
}

- (CGFloat)getHeight
{
    int totalExercises = 0;
    for(WorkoutDay* workoutDay in self.workoutDays) {
        totalExercises += [workoutDay.workoutDayExercises count];
    }
    CGFloat totalHeight = (totalExercises * 70.0f) + ([self.workoutDays count] * 46.0f) + ([self.workoutDays count] * 18.0f);

    return totalHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.workoutDays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[(WorkoutDay *)[self.workoutDays objectAtIndex:section] workoutDayExercises] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 18.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WorkoutDay *workoutDay = (WorkoutDay *)[self.workoutDays objectAtIndex:section];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 46.0f)];
    UIImageView *calendarIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 11, 24, 24)];
    [calendarIcon setImage:[UIImage imageNamed:@"calendar-empty-icon"]];
    [headerView addSubview:calendarIcon];

    UILabel *dayTitle = [[UILabel alloc] init];
    [dayTitle setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0]];
    [dayTitle setText:workoutDay.dayName];
    [dayTitle sizeToFit];
    [dayTitle setFrame:CGRectMake(CGRectGetMaxX(calendarIcon.frame) + 6.0f, calendarIcon.frame.origin.y, dayTitle.frame.size.width, calendarIcon.frame.size.height)];
    [headerView addSubview:dayTitle];

    UILabel *workoutDayTitle = [[UILabel alloc] init];
    [workoutDayTitle setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    [workoutDayTitle setText:workoutDay.title];
    [workoutDayTitle sizeToFit];
    [workoutDayTitle setFrame:CGRectMake(CGRectGetMaxX(dayTitle.frame) + 6.0f, calendarIcon.frame.origin.y, [[UIScreen mainScreen] bounds].size.width - CGRectGetMaxX(dayTitle.frame), calendarIcon.frame.size.height)];
    [headerView addSubview:workoutDayTitle];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkoutDayTableViewCell *cell = (WorkoutDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GEAWorkoutDay"];

    WorkoutDay *workoutDay = [self.workoutDays objectAtIndex:indexPath.section];
    NSMutableSet *workoutDayExercisesMutableSet = [[NSMutableSet alloc] initWithSet:workoutDay.workoutDayExercises];
    NSSortDescriptor *exerciseOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *workoutDayExercises = [workoutDayExercisesMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:exerciseOrderDescriptor]];
    WorkoutDayExercise *workoutDayExercise = [workoutDayExercises objectAtIndex:indexPath.row];

    [[(WorkoutDayTableViewCell *)cell titleLabel] setText:workoutDayExercise.name];
    [[(WorkoutDayTableViewCell *)cell setsAndRepsLabel] setText:[NSString stringWithFormat:@"%d Sets of %@ Reps.", workoutDayExercise.sets, workoutDayExercise.reps]];
    [[(WorkoutDayTableViewCell *)cell restTimeLabel] setText:[NSString stringWithFormat:@"Rest: %d sec.", workoutDayExercise.time]];

    [[GymneaWSClient sharedInstance] requestImageForExercise:workoutDayExercise.exerciseId
                                                    withSize:ExerciseImageSizeMedium
                                                  withGender:ExerciseImageMale
                                                   withOrder:ExerciseImageFirst
                                         withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *exerciseImage) {

                                             if(success==GymneaWSClientRequestSuccess) {

                                                 if(exerciseImage == nil) {
                                                     exerciseImage = [UIImage imageNamed:@"exercise-default-thumbnail"];
                                                 }

                                                 [[(WorkoutDayTableViewCell *)cell thumbnail] setImage:exerciseImage];
                                             }

                                         }];

    cell.thumbnail.layer.cornerRadius = 2.0;
    UIBezierPath *thumbnailShadowPath = [UIBezierPath bezierPathWithRect:cell.thumbnail.bounds];
    cell.thumbnail.layer.shadowPath = thumbnailShadowPath.CGPath;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(willSelectExerciseInWorkoutDayTableViewController:withExerciseId:)]) {

        WorkoutDay *workoutDay = [self.workoutDays objectAtIndex:indexPath.section];
        NSMutableSet *workoutDayExercisesMutableSet = [[NSMutableSet alloc] initWithSet:workoutDay.workoutDayExercises];
        NSSortDescriptor *exerciseOrderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSArray *workoutDayExercises = [workoutDayExercisesMutableSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:exerciseOrderDescriptor]];
        WorkoutDayExercise *workoutDayExercise = [workoutDayExercises objectAtIndex:indexPath.row];

        [self.delegate willSelectExerciseInWorkoutDayTableViewController:self withExerciseId:workoutDayExercise.exerciseId];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
