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
#import "GymneaWSClient.h"
#import "GenericWorkoutsViewController.h"
#import "ExercisesViewController.h"
#import "GEAScrollableTabBarController.h"
#import "ExerciseDetailViewController.h"

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

    
    

    GenericWorkoutsViewController *workoutsViewController = [[GenericWorkoutsViewController alloc] init];
    //[workoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    [workoutsViewController setTitle:@"Generic"];

    
    UIViewController *customWorkoutsViewController = [[UIViewController alloc] init];
    [customWorkoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    [customWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [customWorkoutsViewController setTitle:@"Custom"];

    UIViewController *savedWorkoutsViewController = [[UIViewController alloc] init];
    [savedWorkoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    [savedWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [savedWorkoutsViewController setTitle:@"Saved"];

    UIViewController *assignedWorkoutsViewController = [[UIViewController alloc] init];
    [assignedWorkoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    [assignedWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [assignedWorkoutsViewController setTitle:@"Assigned"];

    UIViewController *currentWorkoutViewController = [[UIViewController alloc] init];
    [currentWorkoutViewController.view setFrame:CGRectMake(0,0,320,690)];
    [currentWorkoutViewController.view setBackgroundColor:[UIColor whiteColor]];
    [currentWorkoutViewController setTitle:@"Current"];

    GEAScrollableTabBarController *scrollableTabBarController = [[GEAScrollableTabBarController alloc] init];
    [scrollableTabBarController.view setFrame:CGRectMake(0,0,320,690)];
    [scrollableTabBarController setViewControllers:@[workoutsViewController, customWorkoutsViewController, savedWorkoutsViewController, assignedWorkoutsViewController, currentWorkoutViewController]];

    UITabBarItem *favorites2TabBarItem = [[UITabBarItem alloc] initWithTitle:@"Workouts" image:[UIImage imageNamed:@"sidebar-workouts-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-workouts-icon"]];
    [scrollableTabBarController setTabBarItem:favorites2TabBarItem];
    UINavigationController *favorites2Controller = [[UINavigationController alloc] initWithRootViewController:scrollableTabBarController];
    [favorites2Controller.interactivePopGestureRecognizer setEnabled:NO];
    favorites2Controller.navigationBar.tintColor = [UIColor colorWithRed:7.0/255.0 green:154.0/255.0 blue:204.0/255.0 alpha:1.0];
    // Add the screen title
    scrollableTabBarController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Workouts" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];




/*
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
*/
    
    
    

    
    
    
    ExercisesViewController *exercisesViewController = [[ExercisesViewController alloc] init];
    [exercisesViewController.view setFrame:CGRectMake(0,0,320,690)];
    [exercisesViewController.view setBackgroundColor:[UIColor whiteColor]];
    [exercisesViewController setTitle:@"Directory"];
    
    UIViewController *savedExercisesViewController = [[UIViewController alloc] init];
    [savedExercisesViewController.view setFrame:CGRectMake(0,0,320,690)];
    [savedExercisesViewController.view setBackgroundColor:[UIColor whiteColor]];
    [savedExercisesViewController setTitle:@"Saved"];
    
    GEAScrollableTabBarController *exercisesScrollableTabBarController = [[GEAScrollableTabBarController alloc] init];
    [exercisesScrollableTabBarController.view setFrame:CGRectMake(0,0,320,690)];
    [exercisesScrollableTabBarController setViewControllers:@[exercisesViewController, savedExercisesViewController]];
    
    UITabBarItem *exercisesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Exercises" image:[UIImage imageNamed:@"sidebar-exercises-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-workouts-icon"]];
    [exercisesScrollableTabBarController setTabBarItem:exercisesTabBarItem];
    UINavigationController *exercisesController = [[UINavigationController alloc] initWithRootViewController:exercisesScrollableTabBarController];
    [exercisesController.interactivePopGestureRecognizer setEnabled:NO];
    exercisesController.navigationBar.tintColor = [UIColor colorWithRed:7.0/255.0 green:154.0/255.0 blue:204.0/255.0 alpha:1.0];
    // Add the screen title
    exercisesScrollableTabBarController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Exercises" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];



/*
    ExerciseDetailViewController *favorites3ViewController = [[ExerciseDetailViewController alloc] initWithEventId:1];
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
    //favorites3ViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Exercises" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];
*/
    
    
    
    
    
    
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


     /*
     signUpWithForm:self.signUpForm
               withCompletionBlock:^(GymneaSignUpWSClientRequestResponse success, NSDictionary *responseData, UserInfo *userInfo) {
                   
                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                   
                   //                   NSLog(@"SIGN IN RESPONSE: %@", responseData);
                   
                   if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"false"]) {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[responseData objectForKey:@"errorMsg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                       [alert show];
                   } else if([[[responseData objectForKey:@"success"] lowercaseString] isEqual: @"true"]){
                       StartViewController *startViewController = [[StartViewController alloc] init];
                       [self.navigationController pushViewController:startViewController animated:NO];
                   } else {
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error occurred. Check your Internet connection and retry again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                       [alert show];
                   }
                   
               }];*/




    // Now we ask fot the session id
    [[GymneaWSClient sharedInstance] requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) {

        // Side menu
        GEASideMenuController *sideMenuController = [[GEASideMenuController alloc] init];
        sideMenuController.viewControllers = @[favoritesController, favorites2Controller, exercisesController, favorites4Controller, favorites5Controller, favorites6Controller];

        [[[UIApplication sharedApplication] keyWindow] setRootViewController:sideMenuController];

    }];
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
