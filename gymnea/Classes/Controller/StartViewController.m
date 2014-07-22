//
//  StartViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "StartViewController.h"
#import "GEASideMenuController.h"
#import "InitialViewController.h"
#import "GEALabel+Gymnea.h"
#import "WorkoutsViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)init
{
    self = [super initWithNibName:@"StartViewController" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIViewController *favoritesViewController = [[UIViewController alloc] init];
    [favoritesViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame = favoritesViewController.navigationController.toolbar.frame;
    frame.origin.y = 20;
    favoritesViewController.navigationController.toolbar.frame = frame;
    favoritesViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [favoritesViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favoritesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dashboard" image:[UIImage imageNamed:@"sidebar-dashboard-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-dashboard-icon"]];
    [favoritesViewController setTabBarItem:favoritesTabBarItem];
    UINavigationController *favoritesController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
    [favoritesController.interactivePopGestureRecognizer setEnabled:NO];
    // Add the screen title
    favoritesViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Dashboard" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    
    
    

    
    WorkoutsViewController *workoutsViewController = [[WorkoutsViewController alloc] init];
    [workoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame2 = workoutsViewController.navigationController.toolbar.frame;
    frame2.origin.y = 20;
    workoutsViewController.navigationController.toolbar.frame = frame2;
    //workoutsViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [workoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favorites2TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Workouts" image:[UIImage imageNamed:@"sidebar-workouts-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-workouts-icon"]];
    [workoutsViewController setTabBarItem:favorites2TabBarItem];
    UINavigationController *favorites2Controller = [[UINavigationController alloc] initWithRootViewController:workoutsViewController];
    [favorites2Controller.interactivePopGestureRecognizer setEnabled:NO];
    favorites2Controller.navigationBar.tintColor = [UIColor colorWithRed:7.0/255.0 green:154.0/255.0 blue:204.0/255.0 alpha:1.0];
    // Add the screen title
    workoutsViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Workouts" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];
    
    
    
    


    UIViewController *favorites3ViewController = [[UIViewController alloc] init];
    [favorites3ViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame3 = favorites3ViewController.navigationController.toolbar.frame;
    frame3.origin.y = 20;
    favorites3ViewController.navigationController.toolbar.frame = frame3;
    favorites3ViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [favorites3ViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favorites3TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Exercises" image:[UIImage imageNamed:@"sidebar-exercises-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-exercises-icon"]];
    [favorites3ViewController setTabBarItem:favorites3TabBarItem];
    UINavigationController *favorites3Controller = [[UINavigationController alloc] initWithRootViewController:favorites3ViewController];
    [favorites3Controller.interactivePopGestureRecognizer setEnabled:NO];
    // Add the screen title
    favorites3ViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Exercises" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    
    
    
    
    
    
    UIViewController *favorites4ViewController = [[UIViewController alloc] init];
    [favorites4ViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame4 = favorites4ViewController.navigationController.toolbar.frame;
    frame4.origin.y = 20;
    favorites4ViewController.navigationController.toolbar.frame = frame4;
    favorites4ViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [favorites4ViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favorites4TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Classes" image:[UIImage imageNamed:@"sidebar-classes-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-classes-icon"]];
    [favorites4ViewController setTabBarItem:favorites4TabBarItem];
    UINavigationController *favorites4Controller = [[UINavigationController alloc] initWithRootViewController:favorites4ViewController];
    [favorites4Controller.interactivePopGestureRecognizer setEnabled:NO];
    // Add the screen title
    favorites4ViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Classes" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];


    

    


    UIViewController *favorites5ViewController = [[UIViewController alloc] init];
    [favorites5ViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame5 = favorites5ViewController.navigationController.toolbar.frame;
    frame5.origin.y = 20;
    favorites5ViewController.navigationController.toolbar.frame = frame5;
    favorites5ViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [favorites5ViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favorites5TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Health Logs" image:[UIImage imageNamed:@"sidebar-health-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-health-icon"]];
    [favorites5ViewController setTabBarItem:favorites5TabBarItem];
    UINavigationController *favorites5Controller = [[UINavigationController alloc] initWithRootViewController:favorites5ViewController];
    [favorites5Controller.interactivePopGestureRecognizer setEnabled:NO];
    // Add the screen title
    favorites5ViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Health / Logs" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    
    
    
    
    
    
    UIViewController *favorites6ViewController = [[UIViewController alloc] init];
    [favorites6ViewController.view setFrame:CGRectMake(0,0,320,690)];
    CGRect frame6 = favorites6ViewController.navigationController.toolbar.frame;
    frame6.origin.y = 20;
    favorites6ViewController.navigationController.toolbar.frame = frame6;
    favorites6ViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [favorites6ViewController.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *favorites6TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Pictures" image:[UIImage imageNamed:@"sidebar-pictures-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-pictures-icon"]];
    [favorites6ViewController setTabBarItem:favorites6TabBarItem];
    UINavigationController *favorites6Controller = [[UINavigationController alloc] initWithRootViewController:favorites6ViewController];
    [favorites6Controller.interactivePopGestureRecognizer setEnabled:NO];
    // Add the screen title
    favorites6ViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Pictures" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];







    // Side menu
    GEASideMenuController *sideMenuController = [[GEASideMenuController alloc] init];
    sideMenuController.viewControllers = @[favoritesController, favorites2Controller, favorites3Controller, favorites4Controller, favorites5Controller, favorites6Controller];

    [[[UIApplication sharedApplication] keyWindow] setRootViewController:sideMenuController];
    //[self.navigationController pushViewController:sideMenuController animated:NO];
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
