//
//  WorkoutDayTableViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 23/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDayTableViewController.h"
#import "WorkoutDayTableViewCell.h"

@interface WorkoutDayTableViewController () //<UITableViewDataSource, UITableViewDelegate>
{
    // Id and model of the review to show
    EventReview *workoutDays;
}

@property (nonatomic, strong) EventReview *workoutDays;

@end


@implementation WorkoutDayTableViewController

@synthesize workoutDays;

- (id)initWithWorkoutDays:(EventReview *)workout_days_
{
    if(self = [super initWithNibName:@"WorkoutDayTableViewController" bundle:nil])
    {
        self.workoutDays = workout_days_;
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
    CGFloat totalHeight = (2 * 5 * 70.0f) + (2 * 46.0f) + (2 * 18.0f);

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width, 46.0f)];
    UIImageView *calendarIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 30, 30)];
    [calendarIcon setImage:[UIImage imageNamed:@"calendar-empty-icon"]];
    [headerView addSubview:calendarIcon];

    UILabel *dayTitle = [[UILabel alloc] init];
    [dayTitle setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0]];
    [dayTitle setText:@"Monday"];
    [dayTitle sizeToFit];
    [dayTitle setFrame:CGRectMake(CGRectGetMaxX(calendarIcon.frame) + 6.0f, calendarIcon.frame.origin.y, dayTitle.frame.size.width, calendarIcon.frame.size.height)];
    [headerView addSubview:dayTitle];

    UILabel *workoutDayTitle = [[UILabel alloc] init];
    [workoutDayTitle setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    [workoutDayTitle setText:@"Chest and Back"];
    [workoutDayTitle sizeToFit];
    [workoutDayTitle setFrame:CGRectMake(CGRectGetMaxX(dayTitle.frame) + 6.0f, calendarIcon.frame.origin.y, [[UIScreen mainScreen] bounds].size.width - CGRectGetMaxX(dayTitle.frame), calendarIcon.frame.size.height)];
    [headerView addSubview:workoutDayTitle];

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GEAWorkoutDay"];

    if(cell == nil)
    {
        cell = [[WorkoutDayTableViewCell alloc] init];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
