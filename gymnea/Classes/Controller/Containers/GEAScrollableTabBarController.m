//
//  GEAScrollableTabBarController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 29/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GEAScrollableTabBarController.h"
#import "GEALabel+Gymnea.h"
#import "GEATouchView.h"

static const CGFloat kVTSTabBarScrollViewWidth = 140.0f;
static const CGFloat kVTSTabBarForwardTapTresshold = 210.0f;
static const CGFloat kVTSTabBarBackTapTresshold = 110.0f;

@interface GEAScrollableTabBarController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong) UIScrollView *tabBarScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, copy) NSMutableArray *labelsArray;

@property (nonatomic) BOOL isScrollingContent;

- (void)removeViewcontrollersSubviews;
- (void)createViewcontrollersSubviews;
- (void)updateLabels;
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture;

@end

@implementation GEAScrollableTabBarController

#pragma mark - Initialization

- (id)init {
  self = [super initWithNibName:nil bundle:nil];
  if (!self) {
    return nil;
  }
  _labelsArray = [NSMutableArray array];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self init];
}

#pragma mark - UIViewController

- (void)loadView {
  // Create and configure the main container UIView
  CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
  self.view = [[UIView alloc] initWithFrame:applicationFrame];
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.view.backgroundColor = [UIColor blackColor];
  
  // Create the tab bar scroll view
  self.tabBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - kVTSTabBarScrollViewWidth) / 2.0f, 0, kVTSTabBarScrollViewWidth, 44.0f)];
  self.tabBarScrollView.clipsToBounds = NO;
  self.tabBarScrollView.backgroundColor = [UIColor clearColor];
  self.tabBarScrollView.alwaysBounceHorizontal = YES;
  self.tabBarScrollView.showsHorizontalScrollIndicator = NO;
  self.tabBarScrollView.showsVerticalScrollIndicator = NO;
  self.tabBarScrollView.pagingEnabled = YES;
  self.tabBarScrollView.delegate = self;
  
  // Create the touch view to support touches outside the tab bar scroll view
  GEATouchView *touchView = [[GEATouchView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.tabBarScrollView.bounds))];
  touchView.touchRedirectionView = self.tabBarScrollView;
  touchView.backgroundColor = [UIColor clearColor];
  
  // Create the bar bar background
  UIImageView *tabBarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.tabBarScrollView.bounds))];
  tabBarBackground.image = [UIImage imageNamed:@"ScrollableTabBarBg"];
  
  // Create the content scroll view
  self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44.0f)];
  self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  self.contentScrollView.backgroundColor = [UIColor whiteColor];
  self.contentScrollView.alwaysBounceHorizontal = YES;
  self.contentScrollView.showsHorizontalScrollIndicator = NO;
  self.contentScrollView.showsVerticalScrollIndicator = NO;
  self.contentScrollView.pagingEnabled = YES;
  self.contentScrollView.delegate = self;
  
  // Create subviews to darken labels and background
//  UIView *leftDarkView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 76, 42)];
//  leftDarkView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
//  UIView *rightDarkView = [[UIView alloc] initWithFrame:CGRectMake(244, 1, 76, 42)];
//  rightDarkView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
  
  // Add created views to main view
  [self.view addSubview:tabBarBackground];
  [self.view addSubview:self.tabBarScrollView];
  [self.view addSubview:self.contentScrollView];
//  [self.view addSubview:leftDarkView];
//  [self.view addSubview:rightDarkView];
  [self.view addSubview:touchView];
}

- (void)viewDidLoad {
  [super viewDidLoad];


  self.edgesForExtendedLayout = UIRectEdgeNone;

  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:nil
                                                                          action:nil];

  if (self.viewControllers) {
    [self createViewcontrollersSubviews];
  }
  
  // Create and attach tap gesture recognizer to tab bar scroll view
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  tapGestureRecognizer.numberOfTouchesRequired = 1;
  [self.tabBarScrollView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidLayoutSubviews {
  // Adjust content size of the scroll view
  self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.contentSize.width, CGRectGetHeight(self.contentScrollView.frame));
}

#pragma mark - Getters and setters

- (void)setViewControllers:(NSArray *)viewControllers {
  if ([_viewControllers isEqualToArray:viewControllers] || (!_viewControllers && !viewControllers)) {
    return;
  }
  
  if (_viewControllers) {
    [self removeViewcontrollersSubviews];
  }
  
  _viewControllers = [viewControllers copy];
  if (_viewControllers && [self isViewLoaded]) {
    [self createViewcontrollersSubviews];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if (scrollView == self.contentScrollView) {
    self.isScrollingContent = YES;
    self.tabBarScrollView.userInteractionEnabled = NO;
  } else {
    self.isScrollingContent = NO;
    self.contentScrollView.userInteractionEnabled = NO;
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    self.tabBarScrollView.userInteractionEnabled = YES;
    self.contentScrollView.userInteractionEnabled = YES;
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  self.tabBarScrollView.userInteractionEnabled = YES;
  self.contentScrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  self.tabBarScrollView.userInteractionEnabled = YES;
  self.contentScrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat scrollViewScale = kVTSTabBarScrollViewWidth / CGRectGetWidth(self.contentScrollView.bounds);
  
  if (scrollView == self.contentScrollView && self.isScrollingContent) {
    CGFloat xOffset = roundf(self.contentScrollView.contentOffset.x * scrollViewScale);
    self.tabBarScrollView.contentOffset = CGPointMake(xOffset, 0.0f);
  } else if (scrollView == self.tabBarScrollView && !self.isScrollingContent) {
    CGFloat xOffset = roundf(self.tabBarScrollView.contentOffset.x / scrollViewScale);
    self.contentScrollView.contentOffset = CGPointMake(xOffset, 0.0f);
  } else {
    return;
  }
  
  [self updateLabels];
}

#pragma mark - Private

- (void)removeViewcontrollersSubviews {
  // Remove labels from scroll view and clear mutable array
  [self.labelsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.labelsArray removeAllObjects];
  
  // Remove viewcontrollers' views from scroll view
  for (UIViewController *childViewController in self.viewControllers) {
    [childViewController willMoveToParentViewController:nil];
    if ([childViewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
      [childViewController beginAppearanceTransition:NO animated:NO];
    }
    [childViewController.view removeFromSuperview];
    if ([childViewController respondsToSelector:@selector(endAppearanceTransition)]) {
      [childViewController endAppearanceTransition];
    }
    [childViewController removeFromParentViewController];
  }
  
  //Reset content offset and content size of scroll views
  self.tabBarScrollView.contentOffset = CGPointZero;
  self.tabBarScrollView.contentSize = CGSizeZero;
  self.contentScrollView.contentOffset = CGPointZero;
  self.contentScrollView.contentSize = CGSizeZero;
}

- (void)createViewcontrollersSubviews {
  CGFloat blueLocations[] = {0.0f, 0.5f, 1.0f};

  UIColor *blueBorderColor = [UIColor colorWithRed:7.0/255.0 green:154.0/255.0 blue:204.0/255.0 alpha:1.0];
  UIColor *blueMiddleColor = [UIColor colorWithRed:11.0f/255.0f green:167.0f/255.0f blue:221.0f/255.0f alpha:1.0];
  NSArray *blueColors = @[(__bridge id)blueBorderColor.CGColor, (__bridge id)blueMiddleColor.CGColor, (__bridge id)blueBorderColor.CGColor];
  CGGradientRef blueGradientColor = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)(blueColors), blueLocations);

  // Add viewControllers' views as subviews of content scroll view
  for (UIViewController *childViewController in self.viewControllers) {
    [self addChildViewController:childViewController];
    if ([childViewController respondsToSelector:@selector(beginAppearanceTransition:animated:)]) {
      [childViewController beginAppearanceTransition:YES animated:NO];
    }
    
    NSUInteger index = [self.viewControllers indexOfObject:childViewController];
    childViewController.view.frame = CGRectMake(index * CGRectGetWidth(self.view.bounds), 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.contentScrollView.bounds));
    [self.contentScrollView addSubview:childViewController.view];

    if ([childViewController respondsToSelector:@selector(endAppearanceTransition)]) {
      [childViewController endAppearanceTransition];
    }
    [childViewController didMoveToParentViewController:self];
    
    // Create labels to show in scrollable tab bar
    GEALabel *blueLabel = [[GEALabel alloc] initWithFrame:CGRectMake(index * kVTSTabBarScrollViewWidth, 8, kVTSTabBarScrollViewWidth, 29)];
    blueLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
    blueLabel.textAlignment = NSTextAlignmentCenter;
    blueLabel.backgroundColor = [UIColor clearColor];
    blueLabel.textColor = [UIColor whiteColor];
    blueLabel.textGradient = blueGradientColor;
    
    GEALabel *silverLabel = [[GEALabel alloc] initWithFrame:CGRectMake(index * kVTSTabBarScrollViewWidth, 8, kVTSTabBarScrollViewWidth, 29)];
    silverLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
    silverLabel.textAlignment = NSTextAlignmentCenter;
    silverLabel.backgroundColor = [UIColor clearColor];
    silverLabel.textColor = [UIColor whiteColor];
    silverLabel.textGradient = blueGradientColor;
    
    blueLabel.text = childViewController.title;
    silverLabel.text = childViewController.title;
    
    [self.labelsArray addObject:blueLabel];
    [self.labelsArray addObject:silverLabel];
    
    [self.tabBarScrollView addSubview:blueLabel];
    [self.tabBarScrollView addSubview:silverLabel];
  }
  
  // Update scroll views contentSizes
  self.tabBarScrollView.contentSize = CGSizeMake(kVTSTabBarScrollViewWidth * [self.viewControllers count], CGRectGetHeight(self.tabBarScrollView.bounds));
  self.contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentScrollView.bounds) * [self.viewControllers count], CGRectGetHeight(self.contentScrollView.bounds));
  
  [self updateLabels];
}

- (void)updateLabels {
  for (UIViewController *viewController in self.viewControllers) {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    GEALabel *blueenLabel = self.labelsArray[index * 2];
    GEALabel *silverLabel = self.labelsArray[index * 2 + 1];
    CGFloat X = ABS(self.contentScrollView.contentOffset.x - CGRectGetMinX(viewController.view.frame));
    if (X < kVTSTabBarScrollViewWidth) {
      blueenLabel.alpha = 1 - X / kVTSTabBarScrollViewWidth;
      silverLabel.alpha = 1 - blueenLabel.alpha;
      
      CGFloat scale = 1 - X / (3 * kVTSTabBarScrollViewWidth);
      blueenLabel.transform = CGAffineTransformMakeScale(scale, scale);
      silverLabel.transform = CGAffineTransformMakeScale(scale, scale);
    } else {
      blueenLabel.alpha = 0.0f;
      silverLabel.alpha = 1.0f;
      CGFloat scale = 2.0f / 3.0f;
      blueenLabel.transform  = CGAffineTransformMakeScale(scale, scale);
      silverLabel.transform  = CGAffineTransformMakeScale(scale, scale);
    }
    
  }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
  if (tapGesture.state == UIGestureRecognizerStateRecognized) {
    CGPoint location = [tapGesture locationInView:self.view];
    if (location.x > kVTSTabBarForwardTapTresshold) {
      CGFloat currentOffset = self.contentScrollView.contentOffset.x;
      CGFloat maxOffset = ([self.viewControllers count] - 1) * CGRectGetWidth(self.contentScrollView.bounds);
      CGFloat nextOffset = MIN(currentOffset + CGRectGetWidth(self.contentScrollView.bounds), maxOffset);
      
      if (nextOffset == currentOffset) {
        return;
      }
      
      self.isScrollingContent = YES;
      self.contentScrollView.userInteractionEnabled = NO;
      self.tabBarScrollView.userInteractionEnabled = NO;
      [self.contentScrollView setContentOffset:CGPointMake(nextOffset, 0) animated:YES];
    } else if (location.x < kVTSTabBarBackTapTresshold) {
      CGFloat currentOffset = self.contentScrollView.contentOffset.x;
      CGFloat previousOffset =  MAX(currentOffset - CGRectGetWidth(self.contentScrollView.bounds), 0.0f) ;
      
      if (currentOffset == previousOffset) {
        return;
      }
      
      self.isScrollingContent = YES;
      self.contentScrollView.userInteractionEnabled = NO;
      self.tabBarScrollView.userInteractionEnabled = NO;
      [self.contentScrollView setContentOffset:CGPointMake(previousOffset, 0) animated:YES];
    }
  }
}

@end
