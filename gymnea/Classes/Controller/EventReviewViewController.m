//
//  ReviewViewController.m
//  Vegas
//
//  Created by Albert Nadal Garriga on 11/04/13.
//  Copyright (c) 2013 Golden Gekko. All rights reserved.
//

#import "EventReviewViewController.h"

static float const kVTSSpaceBetweenLabels = 13.0f;

@interface EventReviewViewController ()
{
    // Id and model of the review to show
    EventReview *review;
}

@property (nonatomic, weak) IBOutlet UILabel *reviewTitle;
@property (nonatomic, weak) IBOutlet UILabel *autorAndDate;
@property (nonatomic, weak) IBOutlet UIImageView *ratingImage;
@property (nonatomic, weak) IBOutlet UIImageView *separator;
@property (nonatomic, weak) IBOutlet UILabel *text;
@property (nonatomic, strong) EventReview *review;

@end

@implementation EventReviewViewController

@synthesize review;

- (id)initWithEventReview:(EventReview *)review_
{
    if(self = [super initWithNibName:@"EventReviewViewController" bundle:nil])
    {
        self.review = review_;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.reviewTitle setText:self.review.title];

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[self.review date]];

    [self.autorAndDate setText:[NSString stringWithFormat:@"by %@, %d/%d/%d", review.author, [dateComponents month], [dateComponents day], [dateComponents year]]];
    [self.text setText:self.review.text];
    [self.text sizeToFit];

    CGRect separatorFrame = self.separator.frame;
    separatorFrame.origin.y = self.text.frame.origin.y + self.text.frame.size.height + kVTSSpaceBetweenLabels;
    self.separator.frame = separatorFrame;

    CGRect viewFrame = self.view.frame;
    viewFrame.size.height = self.separator.frame.origin.y + self.separator.frame.size.height + 1.0f;
    self.view.frame = viewFrame;
}

- (CGFloat)getHeight
{
    return self.view.frame.size.height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
