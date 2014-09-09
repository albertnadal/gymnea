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
#import "CurrentWorkoutDetailViewController.h"
#import "GenericWorkoutsViewController.h"
#import "GenericWorkoutsSavedViewController.h"
#import "GenericWorkoutsDownloadedViewController.h"
#import "ExercisesViewController.h"
#import "ExercisesSavedViewController.h"
#import "ExercisesDownloadedViewController.h"
#import "GEAScrollableTabBarController.h"
#import "ExerciseDetailViewController.h"
#import "PicturesViewController.h"
#import "AccountViewController.h"
#import "GEAAuthentication.h"
#import "GEAAuthenticationKeychainStore.h"

@interface StartViewController ()
{
    BOOL showSplashScreen;
}

@property (nonatomic) BOOL showSplashScreen;

- (void)loadMainContainer;
- (void)initializeLocalData;

@end

@implementation StartViewController

@synthesize showSplashScreen;

- (id)initShowingSplashScreen:(BOOL)showSplash
{
    self = [super initWithNibName:@"StartViewController" bundle:nil];
    if (self)
    {
        self.showSplashScreen = showSplash;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    if(self.showSplashScreen) {
        UIImageView *splashImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [splashImage setImage:[UIImage imageNamed:@"gymnea-initial"]];
        [self.view addSubview:splashImage];
    }

    // Now we ask fot the session id
    [[GymneaWSClient sharedInstance] requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) {


        // Check if is necessary to initialize local data
        GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
        GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
        if(![auth localDataIsInitialized]) {

            // Initialize local data
            [self performSelector:@selector(initializeLocalData) withObject:nil afterDelay:0.01];

        } else {

            // Start loading the main container with the side menu
            [self performSelector:@selector(loadMainContainer) withObject:nil afterDelay:0.01];

        }

    }];
}

- (void)initializeLocalData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

        // Download exercises
        [[GymneaWSClient sharedInstance] requestExercisesWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *exercises) {

            if(success == GymneaWSClientRequestSuccess) {

                // Download workouts
                [[GymneaWSClient sharedInstance] requestWorkoutsWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSArray *workouts) {

                    if(success == GymneaWSClientRequestSuccess) {

                        // Set session as initialized
                        GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
                        GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
                        [auth setLocalDataIsInitialized:YES];
                        [keychainStore setAuthentication:auth forIdentifier:@"gymnea"];

                        // Start loading the main container with the side menu
                        [self loadMainContainer];

                    } else {

                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:@"Unable to reach the network when updating local data."
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Retry", nil];
                        [alert setTag:1];
                        [alert show];

                    }

                }];

            } else {

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to reach the network when updating local data."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Retry", nil];
                [alert setTag:1];
                [alert show];

            }

        }];

    });

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag] == 1)
    {
        // Update local data again
        [self performSelector:@selector(initializeLocalData) withObject:nil afterDelay:0.01];
    }
}

- (void)loadMainContainer
{
/*
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
*/
    
    
    
    CurrentWorkoutDetailViewController *currentWorkoutViewController = [[CurrentWorkoutDetailViewController alloc] init];
    [currentWorkoutViewController setTitle:@"Current"];

    GenericWorkoutsViewController *workoutsViewController = [[GenericWorkoutsViewController alloc] init];
    [workoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [workoutsViewController setTitle:@"Directory"];
/*
    UIViewController *customWorkoutsViewController = [[UIViewController alloc] init];
    [customWorkoutsViewController.view setFrame:CGRectMake(0,0,320,690)];
    [customWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [customWorkoutsViewController setTitle:@"Custom"];
*/
    GenericWorkoutsSavedViewController *savedWorkoutsViewController = [[GenericWorkoutsSavedViewController alloc] init];
    [savedWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [savedWorkoutsViewController setTitle:@"Favorites"];

    GenericWorkoutsDownloadedViewController *downloadedWorkoutsViewController = [[GenericWorkoutsDownloadedViewController alloc] init];
    [downloadedWorkoutsViewController.view setBackgroundColor:[UIColor whiteColor]];
    [downloadedWorkoutsViewController setTitle:@"Downloaded"];

    GEAScrollableTabBarController *scrollableTabBarController = [[GEAScrollableTabBarController alloc] init];
    //scrollableTabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [scrollableTabBarController.view setFrame:CGRectMake(0,0,320,690)];
    [scrollableTabBarController setViewControllers:@[currentWorkoutViewController, workoutsViewController, /*customWorkoutsViewController,*/ savedWorkoutsViewController, downloadedWorkoutsViewController]];

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
    [exercisesViewController.view setBackgroundColor:[UIColor whiteColor]];
    [exercisesViewController setTitle:@"Directory"];
    
    ExercisesSavedViewController *savedExercisesViewController = [[ExercisesSavedViewController alloc] init];
    [savedExercisesViewController.view setBackgroundColor:[UIColor whiteColor]];
    [savedExercisesViewController setTitle:@"Favorites"];

    ExercisesDownloadedViewController *downloadedExercisesViewController = [[ExercisesDownloadedViewController alloc] init];
    [downloadedExercisesViewController.view setBackgroundColor:[UIColor whiteColor]];
    [downloadedExercisesViewController setTitle:@"Downloaded"];

    GEAScrollableTabBarController *exercisesScrollableTabBarController = [[GEAScrollableTabBarController alloc] init];
    [exercisesScrollableTabBarController.view setFrame:CGRectMake(0,0,320,690)];
    [exercisesScrollableTabBarController setViewControllers:@[exercisesViewController, savedExercisesViewController, downloadedExercisesViewController]];
    
    UITabBarItem *exercisesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Exercises" image:[UIImage imageNamed:@"sidebar-exercises-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-exercises-icon"]];
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
    
    
    
    
    
/*
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
*/
    
    
    
    
    
/*
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
*/
    
    
    
    
    
    
    PicturesViewController *picturesViewController = [[PicturesViewController alloc] init];
    picturesViewController.edgesForExtendedLayout = UIRectEdgeNone;
    [picturesViewController.view setBackgroundColor:[UIColor whiteColor]];

    UITabBarItem *picturesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Pictures" image:[UIImage imageNamed:@"sidebar-pictures-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-pictures-icon"]];
    [picturesViewController setTabBarItem:picturesTabBarItem];
    
    UINavigationController *picturesController = [[UINavigationController alloc] initWithRootViewController:picturesViewController];
    [picturesController.interactivePopGestureRecognizer setEnabled:NO];
    picturesViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Pictures" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];


/*    UIViewController *picturesBrowser = [picturesViewController getPhotoBrowser];

    picturesBrowser.edgesForExtendedLayout = UIRectEdgeNone;
    [picturesBrowser.view setBackgroundColor:[UIColor whiteColor]];
    UITabBarItem *picturesTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Pictures" image:[UIImage imageNamed:@"sidebar-pictures-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-pictures-icon"]];
    [picturesBrowser setTabBarItem:picturesTabBarItem];

    UINavigationController *picturesController = [[UINavigationController alloc] initWithRootViewController:picturesBrowser];
    [picturesController.interactivePopGestureRecognizer setEnabled:NO];
    picturesController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Pictures" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];
    */






    
    
    
    
    
    
     AccountViewController *accountViewController = [[AccountViewController alloc] init];
     accountViewController.edgesForExtendedLayout = UIRectEdgeNone;
     [accountViewController.view setBackgroundColor:[UIColor whiteColor]];
     UITabBarItem *accountTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Account" image:[UIImage imageNamed:@"sidebar-account-icon-unselected"] selectedImage:[UIImage imageNamed:@"sidebar-account-icon"]];
     [accountViewController setTabBarItem:accountTabBarItem];
     UINavigationController *accountController = [[UINavigationController alloc] initWithRootViewController:accountViewController];
     [accountController.interactivePopGestureRecognizer setEnabled:NO];
     accountViewController.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Account" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

    
    
    







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



    // Side menu
    GEASideMenuController *sideMenuController = [[GEASideMenuController alloc] init];
    sideMenuController.viewControllers = @[favorites2Controller, exercisesController, picturesController, accountController];

    NSLog(@"Adding side menu controller as root view controller");
    [[[UIApplication sharedApplication] keyWindow] setRootViewController:sideMenuController];
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
