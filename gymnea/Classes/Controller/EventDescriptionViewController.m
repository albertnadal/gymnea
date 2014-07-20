//
//  EventDescriptionViewController.m
//  Vegas
//
//  Created by Albert Nadal Garriga on 12/04/13.
//  Copyright (c) 2013 Golden Gekko. All rights reserved.
//

#import "EventDescriptionViewController.h"
#import "GEALabel+Gymnea.h"
#import "Event.h"

// Paddings and margins
static float const kVTSSpaceBetweenLabels = 10.0f;
static float const kVTSSeparatorMargin = 17.0f;
static float const kVTSContentMargin = 30.0f;

// Sizes of standard iOS controls
static const float kVTSiPhoneStatusBarHeight = 20.0f;
static const float kVTSiPhoneNavigationBarHeight = 44.0f;

@interface EventDescriptionViewController ()

@property (nonatomic, weak) IBOutlet UILabel *eventTitle;
@property (nonatomic, weak) IBOutlet UILabel *eventAuthor;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, weak) IBOutlet UIImageView *separator;
@property (nonatomic, weak) IBOutlet UILabel *description;
@property (nonatomic, weak) IBOutlet UIScrollView *scroll;
@property (nonatomic, strong) Event *event;

@end

@implementation EventDescriptionViewController

- (id)initWithEvent:(Event *)event {
  self = [super initWithNibName:@"EventDescriptionViewController" bundle:nil];
  if (!self) {
    return nil;
  }
  
  self.event = event;
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Add the screen title
  self.navigationItem.titleView = [[GEALabel alloc] initWithText:@"DESCRIPTION" fontSize:20.0f frame:CGRectMake(0.0f,0.0f,200.0f,30.0f)];
  
  [self.backgroundImage setImage:[[UIImage imageNamed:@"img_description_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f)]];
  
  [self.eventTitle setText:self.event.title];
  [self.eventTitle sizeToFit];
  
  CGRect eventTitleFrame = self.eventTitle.frame;
  CGFloat baseYPosition = eventTitleFrame.origin.y + eventTitleFrame.size.height + kVTSSpaceBetweenLabels;
  
#warning Please show the company name when we have this info in the model
  [self.eventAuthor setText:[NSString stringWithFormat:@"by %@", @"Gerry McCambridge"/*self.event.company*/]];
  [self.eventAuthor sizeToFit];
  
  CGRect eventAuthorFrame = self.eventAuthor.frame;
  eventAuthorFrame.origin.y = baseYPosition;
  self.eventAuthor.frame = eventAuthorFrame;
  
  baseYPosition+=(eventAuthorFrame.size.height + kVTSSeparatorMargin);
  CGRect separatorFrame = self.separator.frame;
  separatorFrame.origin.y = baseYPosition;
  self.separator.frame = separatorFrame;
  
  baseYPosition+=kVTSSeparatorMargin;
  
  [self.description setText:self.event.eventDescription];
  [self.description sizeToFit];
  
  CGRect descriptionFrame = self.description.frame;
  descriptionFrame.origin.y = baseYPosition;
  self.description.frame = descriptionFrame;
  
  baseYPosition+=(descriptionFrame.size.height+kVTSContentMargin);
  CGRect backgroundImageFrame = self.backgroundImage.frame;
  
  CGRect scrollFrame = self.scroll.frame;
  scrollFrame.size.height = [UIApplication sharedApplication].keyWindow.frame.size.height - kVTSiPhoneStatusBarHeight - kVTSiPhoneNavigationBarHeight;
  [self.scroll setFrame:scrollFrame];
  
  if(baseYPosition > self.scroll.frame.size.height) {
    [self.scroll setScrollEnabled:YES];
    backgroundImageFrame.size.height = baseYPosition;
  } else {
    [self.scroll setScrollEnabled:NO];
    backgroundImageFrame.size.height = [UIApplication sharedApplication].keyWindow.frame.size.height - kVTSiPhoneStatusBarHeight - kVTSiPhoneNavigationBarHeight;
  }
  
  [self.backgroundImage setFrame:backgroundImageFrame];
  [self.scroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, baseYPosition)];
}

@end
