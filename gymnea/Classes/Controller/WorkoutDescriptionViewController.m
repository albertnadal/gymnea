//
//  WorkoutDescriptionViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 12/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "WorkoutDescriptionViewController.h"
#import "GEALabel+Gymnea.h"
#import "Exercise.h"

// Paddings and margins
static float const kGEASpaceBetweenLabels = 10.0f;
static float const kGEASeparatorMargin = 17.0f;
static float const kGEAContentMargin = 30.0f;

// Sizes of standard iOS controls
static const float kGEAiPhoneStatusBarHeight = 20.0f;
static const float kGEAiPhoneNavigationBarHeight = 44.0f;

@interface WorkoutDescriptionViewController ()

@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UILabel *eventAuthor;
@property (nonatomic, weak) IBOutlet UIView *separator;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) Exercise *event;

@end

@implementation WorkoutDescriptionViewController

- (id)initWithEvent:(Exercise *)event {
  self = [super initWithNibName:@"WorkoutDescriptionViewController" bundle:nil];
  if (!self) {
    return nil;
  }
  
  self.event = event;
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.edgesForExtendedLayout = UIRectEdgeNone;

  // Add the screen title
  self.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Workout guide" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

/*
  [self.eventTitle setText:self.event.title];
  [self.eventTitle sizeToFit];
*/
  CGRect eventTitleFrame = self.eventTitle.frame;
  CGFloat baseYPosition = eventTitleFrame.origin.y + eventTitleFrame.size.height + kGEASpaceBetweenLabels;
  
#warning Please show the company name when we have this info in the model
  [self.eventAuthor setText:[NSString stringWithFormat:@"by %@", @"Gymnea"/*self.event.company*/]];
  [self.eventAuthor sizeToFit];
  
  CGRect eventAuthorFrame = self.eventAuthor.frame;
  eventAuthorFrame.origin.y = baseYPosition;
  self.eventAuthor.frame = eventAuthorFrame;
  
  baseYPosition+=(eventAuthorFrame.size.height + kGEASeparatorMargin);
  CGRect separatorFrame = self.separator.frame;
  separatorFrame.origin.y = baseYPosition;
  self.separator.frame = separatorFrame;
  
  baseYPosition+=kGEASeparatorMargin;
/*
  [self.description setText:self.event.eventDescription];
  [self.description sizeToFit];
*/
  CGRect descriptionFrame = self.description.frame;
  descriptionFrame.origin.y = baseYPosition;
  self.description.frame = descriptionFrame;
  
  baseYPosition+=(descriptionFrame.size.height+kGEAContentMargin);
  
  CGRect scrollFrame = self.scroll.frame;
  scrollFrame.size.height = [UIApplication sharedApplication].keyWindow.frame.size.height - kGEAiPhoneStatusBarHeight - kGEAiPhoneNavigationBarHeight;
  [self.scroll setFrame:scrollFrame];
  
  if(baseYPosition > self.scroll.frame.size.height) {
    [self.scroll setScrollEnabled:YES];
  } else {
    [self.scroll setScrollEnabled:NO];
  }

  [self.scroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, baseYPosition)];
}

@end
