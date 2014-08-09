//
//  GEASideMenuController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GEASideMenuController.h"
#import "GymneaWSClient.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const CGFloat kGEASideMenuViewTopSeparation = 83.0f;
static const CGFloat kGEASideMenuViewTopInset568ScreenDevice = 25.0f;
static const CGFloat kGEASideMenuViewTopInset320ScreenDevice = 14.5f;
static const CGFloat kGEASideMenuViewLeftInset = 20.0f;

static const CGFloat kGEASideMenuViewItemHeight = 36.0f;
static const CGFloat kGEASideMenuViewItemWidth = 200.0f;
static const CGFloat kGEASideMenuViewItemIconAndTextSpacing = 12.0f;

static const CGFloat kGEASideMenuViewItemTitleFontSize = 20.0f;

static const CGFloat kGEAMainViewScaleOffset = 0.60;
static const CGFloat kGEAMainViewContainerOffset = 240.0f;
static const CGFloat kGEAVelocityTresshold = 200.0f;

static const CGFloat kGEAOpenCloseAnimationDuration = 0.3f;

#pragma mark GEASideMenuView

@class GEASideMenuView;

@protocol GEASideMenuViewDelegate <NSObject>

- (void)sideMenuView:(GEASideMenuView *)sideMenuView didSelectItem:(UITabBarItem *)item;

@end


@interface GEASideMenuView : UIView

@property (nonatomic, weak) id<GEASideMenuViewDelegate> delegate;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, weak) UITabBarItem *selectedItem;
@property (nonatomic, strong) NSMutableArray *tabBarButtons;

- (void)updateTabBarButtons;
- (void)didTouchDownBarButton:(UIButton *)button;

@end

@implementation GEASideMenuView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;
  }

  _tabBarButtons = [NSMutableArray array];
  
  return self;
}

#pragma mark - Getters and setters

- (void)setItems:(NSArray *)items {
  if ([_items isEqualToArray:items]) {
    return;
  }
  
  _items = [items copy];
  _selectedItem = nil;

  // Regenerate UIButtons in tabBarButtons array
  [self.tabBarButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.tabBarButtons removeAllObjects];

  // Calculate the vertical button separation depending on screen height
  CGFloat buttonSeparation = ([[UIScreen mainScreen] bounds].size.height == 568.0f) ? kGEASideMenuViewTopInset568ScreenDevice : kGEASideMenuViewTopInset320ScreenDevice;

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat screenHeight = screenRect.size.height;

  CGFloat maxTopSeparation = MAX((screenHeight - (screenHeight * kGEAMainViewScaleOffset)) / 2.0f, kGEASideMenuViewTopSeparation);

  for (UITabBarItem *item in _items) {
    NSUInteger index = [_items indexOfObject:item];

    UIButton *tabBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                        (index ? (index * (kGEASideMenuViewItemHeight + buttonSeparation)) + maxTopSeparation : maxTopSeparation),
                                                                        CGRectGetWidth(self.bounds),
                                                                        kGEASideMenuViewItemHeight)];

    [tabBarButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    tabBarButton.adjustsImageWhenHighlighted = NO;
    tabBarButton.backgroundColor = [UIColor clearColor];
    tabBarButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:kGEASideMenuViewItemTitleFontSize];
    tabBarButton.tag = [_items indexOfObject:item];
    [tabBarButton addTarget:self action:@selector(didTouchDownBarButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:tabBarButton];
    [self.tabBarButtons addObject:tabBarButton];
  }
  [self updateTabBarButtons];
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem {
  if ([_selectedItem isEqual:selectedItem]) {
    return;
  }
  _selectedItem = selectedItem;
  [self updateTabBarButtons];
}

- (void)updateTabBarButtons {
  for (UITabBarItem *item in self.items) {
    UIButton *button = self.tabBarButtons[ [self.items indexOfObject:item] ];
    [button setTitle:[item.title uppercaseString]
            forState:UIControlStateNormal];
    
    if (![item isEqual:self.selectedItem]) {
      [button setImage:item.image
              forState:UIControlStateNormal];
      [button setTitleColor:[UIColor colorWithRed:186.0/255.0 green:240.0/255.0 blue:255.0/255.0 alpha:1.0]
                   forState:UIControlStateNormal];
      [button setTitleShadowColor:[UIColor clearColor]
                         forState:UIControlStateNormal];
    } else {
      [button setImage:item.selectedImage
              forState:UIControlStateNormal];
      [button setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
      [button setTitleShadowColor:[UIColor clearColor]
                         forState:UIControlStateNormal];
    }


    // Calculate the content inset
    //NSUInteger index = [self.items indexOfObject:item];
    CGFloat horizontalContentInset = CGRectGetWidth(self.bounds) - kGEASideMenuViewItemWidth;
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, kGEASideMenuViewLeftInset, 0.0f, horizontalContentInset - kGEASideMenuViewLeftInset);

    // lower the text and push it left to center it
    button.titleEdgeInsets = UIEdgeInsetsMake(5.0f, kGEASideMenuViewItemIconAndTextSpacing, 0.0f, 0.0f);

    // raise the image and push it right to center it
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
  }
}

- (void)didTouchDownBarButton:(UIButton *)button {
  self.selectedItem = self.items[button.tag];
  if ([self.delegate respondsToSelector:@selector(sideMenuView:didSelectItem:)]) {
    [self.delegate sideMenuView:self didSelectItem:self.selectedItem];
  }
}

@end


#pragma mark - GEASideMenuController

@interface GEASideMenuController () <GEASideMenuViewDelegate>

@property (nonatomic, strong) GEASideMenuView *sideMenuView;
@property (nonatomic, strong) UIView *mainViewContainer;
@property (nonatomic, strong) UIView *tapCaptureView;
@property (nonatomic, retain) IBOutlet UIView *userInformationView;
@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *userInfoLabel;
@property (nonatomic, retain) IBOutlet UIImageView *userPicture;


- (void)changeChildViewController:(UIViewController *)childViewController withViewController:(UIViewController *)viewController;
- (void)setupChildViewControllersForSideViewVisibility:(BOOL)hidden;
- (void)didTouchOpenCloseButton:(UIBarButtonItem *)openCloseButton;
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture;

@end

@implementation GEASideMenuController

#pragma mark - Initialization

// Designated initializer
- (id)init {
  self = [super initWithNibName:@"GEASideMenuController" bundle:nil];
  if (!self) {
    return nil;
  }
  
  _selectedIndex = NSNotFound;
  _sideMenuHidden = YES;
  
  return self;
}
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self init];
}*/

#pragma mark - UIViewController
/*
- (void)loadView {
  // Create and configure the main container UIView


  CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
  self.view = [[UIView alloc] initWithFrame:applicationFrame];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.view.backgroundColor = [UIColor colorWithRed:5.0/255.0 green:195.0/255.0 blue:249.0/255.0 alpha:1.0];

}*/

- (void)viewDidLoad {

    [super viewDidLoad];

    // Create and configure the side menu view
    self.sideMenuView = [[GEASideMenuView alloc] initWithFrame:self.view.bounds];
    self.sideMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.sideMenuView.backgroundColor = [UIColor clearColor];
    self.sideMenuView.delegate = self;
    [self.view addSubview:self.sideMenuView];
    
    // Create the main view container
    self.mainViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    self.mainViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mainViewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.mainViewContainer];
    
    // Create a view to capture taps when side view is visible
    self.tapCaptureView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tapCaptureView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tapCaptureView.backgroundColor = [UIColor clearColor];
    [self.mainViewContainer addSubview:self.tapCaptureView];


  if (self.viewControllers) {
    NSMutableArray *tabBarItemsArray = [NSMutableArray array];
    for (UIViewController *viewController in _viewControllers) {
      [tabBarItemsArray addObject:viewController.tabBarItem];
    }
    [self.sideMenuView setItems:tabBarItemsArray];
    if (self.viewControllers.count > 0) {
      self.selectedIndex = 0;
    }
  }

  // Create the pan gesture recognizer to handle swipe to show/hide menu
  UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  [self.mainViewContainer addGestureRecognizer:panGestureRecognizer];

  // Create the tap gesture recognizer
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  [self.tapCaptureView addGestureRecognizer:tapGestureRecognizer];

    // Make the user picture full rounded
    UIBezierPath *userPictureViewShadowPath = [UIBezierPath bezierPathWithRect:self.userPicture.bounds];
    self.userPicture.layer.shadowPath = userPictureViewShadowPath.CGPath;
    self.userPicture.layer.rasterizationScale = 2;
    self.userPicture.layer.cornerRadius = self.userPicture.frame.size.width / 2.0f;;
    self.userPicture.layer.masksToBounds = YES;


    // Download the user information or get it from the DB
    [[GymneaWSClient sharedInstance] requestUserInfoWithCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, UserInfo *userInfo) {


        if(success == GymneaWSClientRequestSuccess) {

            // Calculate the user age from his birthdate
            NSDate *today = [[NSDate alloc] init];
            NSCalendar *sysCalendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSYearCalendarUnit;
            NSDate *differentialDate = [[NSDate alloc] initWithTimeInterval:[[userInfo birthDate] timeIntervalSinceNow] sinceDate:today];
            NSDateComponents *userAgeComponents = [sysCalendar components:unitFlags fromDate:today  toDate:differentialDate  options:0];

            // Calculate the user height (cm <-> ft/in)
            float centimeters = [userInfo heightCentimeters];
            NSString *heightString = nil;

            if([userInfo heightIsMetric]) {
                heightString = [NSString stringWithFormat:@"%.0fcm", centimeters];
            } else {
                float inches = (centimeters * 0.39370078740157477f);
                int feet = (int)(inches / 12);
                inches = fmodf(inches, 12);
                heightString = [NSString stringWithFormat:@"%d' %.2f\"", feet, inches];
            }

            // Calculate the user weight
            float kilograms = [userInfo weightKilograms];
            NSString *weightString = nil;
            
            if([userInfo weightIsMetric]) {
                weightString = [NSString stringWithFormat:@"%.1fkg", kilograms];
            } else {
                weightString = [NSString stringWithFormat:@"%.1flbs", (kilograms * 2.20462262f)];
            }

            [self.userInfoLabel setText:[NSString stringWithFormat:@"%@ - %d - %@ - %@", [userInfo.gender capitalizedString], abs([userAgeComponents year]), heightString, weightString]];
            [self.userNameLabel setText:[NSString stringWithFormat:@"%@ %@", userInfo.firstName, userInfo.lastName]];

        } else {
            [self.userNameLabel setText:@"-"];
            [self.userInfoLabel setText:@"-"];

        }

        //Download the user avatar picture
        [[GymneaWSClient sharedInstance] requestUserImageWithCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *userImage) {
            
            if(success == GymneaWSClientRequestSuccess) {
                [self.userPicture setImage:userImage];
            }
            
        }];

    }];
}

#pragma mark - Getters and setters

- (void)setViewControllers:(NSArray *)viewControllers {
  if ([_viewControllers isEqualToArray:viewControllers] || (!_viewControllers && !viewControllers)) {
    return;
  }

  self.selectedIndex = NSNotFound;

  _viewControllers = [viewControllers copy];

  NSMutableArray *tabBarItemsArray = [NSMutableArray array];
  for (UIViewController *viewController in _viewControllers) {
    [tabBarItemsArray addObject:viewController.tabBarItem];
    viewController.sideMenuController = self;
  }

  [self.sideMenuView setItems:tabBarItemsArray];

  if (self.mainViewContainer && _viewControllers && _viewControllers.count > 0) {
    self.selectedIndex = 0;
  }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
  if ([_selectedViewController isEqual:selectedViewController] || (!_selectedViewController && !selectedViewController)) {
    if ([_selectedViewController isKindOfClass:[UINavigationController class] ]) {
      [(UINavigationController *) _selectedViewController popToRootViewControllerAnimated:YES];
    }
    return;
  }

    // Create the left bar button item
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60.0f, 44.0f)];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundColor:[UIColor yellowColor]];
    backButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 44.0f);

    [backView addSubview:backButton];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc]initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = customBarItem;

    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"side-menu-button"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(didTouchOpenCloseButton:)];

    if ([selectedViewController isKindOfClass:[UINavigationController class] ]) {
        UINavigationController *navController = (UINavigationController *)selectedViewController;
        UIViewController *rootViewController = (UIViewController *)navController.viewControllers[0];
        rootViewController.sideMenuController = self;

        // First UIViewController must not have a left margin space in the navigation bar
        NSInteger selectedViewControllerIndex = [self.viewControllers indexOfObject:selectedViewController];
        
        rootViewController.navigationItem.leftBarButtonItems = selectedViewControllerIndex ? @[/*fixedSpace,*/ leftBarButtonItem] : @[leftBarButtonItem];
    } else {
        selectedViewController.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }

  [self changeChildViewController:_selectedViewController
               withViewController:selectedViewController];

  _selectedViewController = selectedViewController;


  if (_selectedViewController) {
    _selectedIndex = [self.viewControllers indexOfObject:_selectedViewController];
    [self.sideMenuView setSelectedItem:_selectedViewController.tabBarItem];
  } else {
    _selectedIndex = NSNotFound;
    [self.sideMenuView setSelectedItem:nil];
  }
  
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
  if (selectedIndex != NSNotFound) {
      self.selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
  } else {
    self.selectedViewController = nil;
  }
}

#pragma mark - Show/hide the sideViewController

- (void)setSideMenuHidden:(BOOL)sideMenuHidden {
  [self setSideMenuHidden:sideMenuHidden animated:NO];
}

- (void)setSideMenuHidden:(BOOL)hidden
                 animated:(BOOL)animated {
  _sideMenuHidden = hidden;
  
  if (animated) {
    [UIView animateWithDuration:kGEAOpenCloseAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                       [self setupChildViewControllersForSideViewVisibility:hidden];
                     }
                     completion:nil];
  } else {
    [self setupChildViewControllersForSideViewVisibility:hidden];
  }
}

#pragma mark - GEASideMenuViewDelegate

- (void)sideMenuView:(GEASideMenuView *)sideMenuView didSelectItem:(UITabBarItem *)item {
  self.selectedIndex = [self.sideMenuView.items indexOfObject:item];
  [self setSideMenuHidden:YES animated:YES];
}

#pragma mark - Private methods

- (void)changeChildViewController:(UIViewController *)childViewController
               withViewController:(UIViewController *)viewController {
  if ( [childViewController isEqual:viewController] || (!childViewController && !viewController) ) {
    return;
  }
  
  [childViewController willMoveToParentViewController:nil];
  if (viewController) {
    [self addChildViewController:viewController];
  }

  if (viewController) {
    if (childViewController) {
      [childViewController.view removeFromSuperview];
      [self.mainViewContainer addSubview:viewController.view];
    } else {
      [self.mainViewContainer addSubview:viewController.view];
    }
  }

  [childViewController.view removeFromSuperview];
  [childViewController removeFromParentViewController];
  [viewController didMoveToParentViewController:self];
  
  childViewController = viewController;

  [viewController.view setNeedsDisplay];
}

- (void)setupChildViewControllersForSideViewVisibility:(BOOL)hidden {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

  if (hidden) {

      [UIView beginAnimations:@"mainViewControllerZoomIn" context:NULL];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDuration:kGEAOpenCloseAnimationDuration];

      CGAffineTransform zooming = CGAffineTransformMakeScale(1.0, 1.0);
      self.mainViewContainer.transform = zooming;
      [UIView commitAnimations];


    self.mainViewContainer.frame = CGRectMake(0, 0,
                                              screenWidth,
                                              screenHeight);

    [self.mainViewContainer sendSubviewToBack:self.tapCaptureView];

  } else {

      [UIView beginAnimations:@"mainViewControllerZoomOut" context:NULL];
      [UIView setAnimationDelegate:self];
      [UIView setAnimationDuration:kGEAOpenCloseAnimationDuration];
      CGAffineTransform zooming = CGAffineTransformMakeScale(kGEAMainViewScaleOffset, kGEAMainViewScaleOffset);
      self.mainViewContainer.transform = zooming;
      [UIView commitAnimations];


    self.mainViewContainer.frame = CGRectMake(kGEAMainViewContainerOffset, (screenHeight - (screenHeight * kGEAMainViewScaleOffset)) / 2.0f,
                                              screenWidth * kGEAMainViewScaleOffset,
                                              screenHeight * kGEAMainViewScaleOffset);

      [self.mainViewContainer bringSubviewToFront:self.tapCaptureView];
  }
}

- (void)didTouchOpenCloseButton:(UIBarButtonItem *)openCloseButton {
  [self setSideMenuHidden:!self.sideMenuHidden
                 animated:YES];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {

  switch (panGesture.state) {
    case UIGestureRecognizerStateBegan:
      self.sideMenuView.userInteractionEnabled = NO;
    case UIGestureRecognizerStateChanged: {
      CGFloat xOffset = [panGesture translationInView:self.view].x + (self.sideMenuHidden ? 0 : kGEAMainViewContainerOffset);
      if (xOffset < 0) {
        xOffset = 0;
      } else if (xOffset > kGEAMainViewContainerOffset) {
        // Elasticity adjustement
        CGFloat xOffsetAdjustment = xOffset - kGEAMainViewContainerOffset;
        xOffsetAdjustment = roundf( xOffsetAdjustment / logf(xOffsetAdjustment + 1) * 2 );
        xOffset = kGEAMainViewContainerOffset + xOffsetAdjustment;
      }

        [UIView beginAnimations:@"mainViewControllerZooming" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.000001f];

        CGFloat scale = 1.0f - MIN(((xOffset * (1.0f - kGEAMainViewScaleOffset)) / kGEAMainViewContainerOffset), 1.0f);
        CGAffineTransform zooming = CGAffineTransformMakeScale(scale, scale);
        self.mainViewContainer.transform = zooming;

        [UIView commitAnimations];

        CGRect mainViewContainerFrame = self.mainViewContainer.frame;
        mainViewContainerFrame.origin.x = 0.0f + xOffset;
        self.mainViewContainer.frame = mainViewContainerFrame;
    }
      break;
    case UIGestureRecognizerStateEnded: {
      CGFloat xOffset = [panGesture translationInView:self.view].x + (self.sideMenuHidden ? 0 : kGEAMainViewContainerOffset);
      CGFloat xVelocity = [panGesture velocityInView:self.view].x;
      if (ABS(xVelocity) >= kGEAVelocityTresshold) {
        if (xVelocity > 0) {
          [self setSideMenuHidden:NO animated:YES];
        } else {
          [self setSideMenuHidden:YES animated:YES];
        }
      } else if (xOffset <= (kGEAMainViewContainerOffset / 2.0f)) {
        [self setSideMenuHidden:YES animated:YES];
      } else {
        [self setSideMenuHidden:NO animated:YES];
      }
      self.sideMenuView.userInteractionEnabled = YES;
    }
      break;
    case UIGestureRecognizerStateCancelled:
      [self setSideMenuHidden:self.sideMenuHidden animated:YES];
      self.sideMenuView.userInteractionEnabled = YES;
      break;
    default:
      break;
  }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
  [self setSideMenuHidden:YES animated:YES];
}

@end


#pragma mark - UIViewController (GEASideMenuController)

static char UIViewControllerSideMenuControllerKey;

@implementation UIViewController (GEASideMenuController)

- (void)setSideMenuController:(GEASideMenuController *)sideMenuController {
  [self willChangeValueForKey:@"sideMenuController"];
  objc_setAssociatedObject(self, &UIViewControllerSideMenuControllerKey, sideMenuController, OBJC_ASSOCIATION_ASSIGN);
  [self didChangeValueForKey:@"sideMenuController"];
}

- (GEASideMenuController *)sideMenuController {
  return objc_getAssociatedObject(self, &UIViewControllerSideMenuControllerKey);
}

@end
