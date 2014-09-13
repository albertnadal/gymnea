//
//  ChooseWorkoutDayTableViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 25/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ChooseWorkoutDayTableViewController.h"
#import "ChooseWorkoutDayTableViewCell.h"
#import "WorkoutPlayViewController.h"
#import "WorkoutDay+Management.h"

@interface ChooseWorkoutDayTableViewController ()
{
    NSArray *workoutDays;
}

@property (nonatomic, strong) NSArray *workoutDays;

@end

@implementation ChooseWorkoutDayTableViewController

@synthesize workoutDays;

- (id)initWithWorkoutDays:(NSArray *)workout_days_ withDelegate:(id<ChooseWorkoutDayTableViewControllerDelegate>)delegate_
{
    if(self = [super init])
    {
        self.delegate = delegate_;
        self.workoutDays = workout_days_;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"ChooseWorkoutDayTableViewCell" bundle:nil] forCellReuseIdentifier:@"GEAChooseWorkoutDay"];
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
    return [self.workoutDays count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseWorkoutDayTableViewCell *cell = (ChooseWorkoutDayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GEAChooseWorkoutDay"];

    WorkoutDay *workoutDay = [self.workoutDays objectAtIndex:indexPath.section];
    int workoutDayTotalExercises = (int)[[[NSMutableSet alloc] initWithSet:workoutDay.workoutDayExercises] count];

    [[(ChooseWorkoutDayTableViewCell *)cell titleLabel] setText:workoutDay.title];
    [[(ChooseWorkoutDayTableViewCell *)cell titleLabel] sizeToFit];
    [[(ChooseWorkoutDayTableViewCell *)cell dayLabel] setText:workoutDay.dayName];
    [[(ChooseWorkoutDayTableViewCell *)cell dayLabel] sizeToFit];
    [[(ChooseWorkoutDayTableViewCell *)cell totalExercisesLabel] setText:[NSString stringWithFormat:@"%d exercises", workoutDayTotalExercises]];
    [[(ChooseWorkoutDayTableViewCell *)cell totalExercisesLabel] sizeToFit];

    CGRect dayLabelFrame = [(ChooseWorkoutDayTableViewCell *)cell dayLabel].frame;
    dayLabelFrame.origin.y = 10.0f;
    dayLabelFrame.size.height = 20.0f;
    [[(ChooseWorkoutDayTableViewCell *)cell dayLabel] setFrame:dayLabelFrame];

    CGRect titleLabelFrame = [(ChooseWorkoutDayTableViewCell *)cell titleLabel].frame;
    titleLabelFrame.origin.y = 10.0f;
    titleLabelFrame.origin.x = CGRectGetMaxX(dayLabelFrame) + 10.0f;
    titleLabelFrame.size.width = [UIScreen mainScreen].bounds.size.width - titleLabelFrame.origin.x - 10.f;
    titleLabelFrame.size.height = 20.0f;
    [[(ChooseWorkoutDayTableViewCell *)cell titleLabel] setFrame:titleLabelFrame];


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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(willSelectRowInChooseWorkoutViewController:atRowIndex:)])
        [self.delegate willSelectRowInChooseWorkoutViewController:self atRowIndex:indexPath.section];
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
