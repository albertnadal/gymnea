//
//  ExerciseDescriptionViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 04/08/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "ExerciseDescriptionViewController.h"
#import "GEALabel+Gymnea.h"

// Paddings and margins
static float const kGEASpaceBetweenLabels = 10.0f;
static float const kGEASeparatorMargin = 17.0f;
static float const kGEAContentMargin = 30.0f;

// Sizes of standard iOS controls
static const float kGEAiPhoneStatusBarHeight = 20.0f;
static const float kGEAiPhoneNavigationBarHeight = 44.0f;

@interface ExerciseDescriptionViewController ()
{
    NSString *exerciseName;
    NSString *exerciseDescription;
}

@property (nonatomic, retain) NSString *exerciseName;
@property (nonatomic, retain) NSString *exerciseDescription;
@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UILabel *eventAuthor;
@property (nonatomic, weak) IBOutlet UIView *separator;
@property (nonatomic, weak) IBOutlet UILabel *theDescription;
@property (nonatomic, weak) IBOutlet UIScrollView *scroll;

@end

@implementation ExerciseDescriptionViewController

@synthesize exerciseName;
@synthesize exerciseDescription;

- (id)initWithName:(NSString *)name withDescription:(NSString *)description {
  self = [super initWithNibName:@"ExerciseDescriptionViewController" bundle:nil];
  if (!self) {
      return nil;
  }

  self.exerciseName = name;
  self.exerciseDescription = description;

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.edgesForExtendedLayout = UIRectEdgeNone;

  // Add the screen title
  self.navigationItem.titleView = [[GEALabel alloc] initWithText:@"Exercise guide" fontSize:21.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];

  [self.eventTitle setText:self.exerciseName];
  [self.eventTitle sizeToFit];
  
  CGRect eventTitleFrame = self.eventTitle.frame;
  CGFloat baseYPosition = eventTitleFrame.origin.y + eventTitleFrame.size.height + kGEASpaceBetweenLabels;
  
  [self.eventAuthor setText:[NSString stringWithFormat:@"by %@", @"Gymnea"]];
  [self.eventAuthor sizeToFit];
  
  CGRect eventAuthorFrame = self.eventAuthor.frame;
  eventAuthorFrame.origin.y = baseYPosition;
  self.eventAuthor.frame = eventAuthorFrame;
  
  baseYPosition+=(eventAuthorFrame.size.height + kGEASeparatorMargin);
  CGRect separatorFrame = self.separator.frame;
  separatorFrame.origin.y = baseYPosition;
  self.separator.frame = separatorFrame;
  
  baseYPosition+=kGEASeparatorMargin;
  
  [self.theDescription setText:self.exerciseDescription];
  [self.theDescription sizeToFit];
  
  CGRect descriptionFrame = self.theDescription.frame;
  descriptionFrame.origin.y = baseYPosition;
  self.theDescription.frame = descriptionFrame;
  
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"ExerciseDescriptionViewController";
}

@end
