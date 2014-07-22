//
//  WorkoutsViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 21/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutsViewController.h"
#import "EventDetailViewController.h"


@interface WorkoutsViewController ()

- (IBAction)showWorkoutDetails:(id)sender;

@end

@implementation WorkoutsViewController

- (id)init
{
    self = [super initWithNibName:@"WorkoutsViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (IBAction)showWorkoutDetails:(id)sender
{
    EventDetailViewController *viewController = [[EventDetailViewController alloc] initWithEventId:1];

    [viewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame2 = viewController.navigationController.toolbar.frame;
    frame2.origin.y = 20;
    viewController.navigationController.toolbar.frame = frame2;
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
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
