//
//  GEAPopoverViewController.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/03/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "QuartzCore/QuartzCore.h"
#import "GEAPopoverViewController.h"

// Sizes
static const float kGEAPopoverContentWidth = 188.0f; //148.0f;
static const float kGEAPopoverContentRowHeight = 44.0f;
static const float kGEAPopoverContentSeparatorHeight = 2.0f;
static const float kGEAPopoverMaxContentHeight = 350.0f;
static const float kGEAPopoverTailWidth = 23.0f;
static const float kGEAPopoverTailHeight = 13.0f;
static const float kGEAPopoverTableCellHeight = 17.0f;
static const float kGEAPopoverIconWidth = 20.0f;
static const float kGEAPopoverIconHeight = 20.0f;
static const float kGEAPopoverTextWidth = 140.0f;
static const float kGEAPopoverTextHeight = 20.0f;

// Sizes of standard iOS controls
static const float kGEAiPhoneStatusBarHeight = 20.0f;
static const float kGEAiPhoneNavigationBarHeight = 44.0f;

// Paddings and margins
static const float kGEAPopoverUIToolbarMargin = 5.0f;
static const float kGEAPopoverContentHorizontalPadding = 9.0f;
static const float kGEAPopoverContentVerticalPadding = 73.0f;
static const float kGEAPopoverContentVerticalMargin = 2.0f;//4.0f;
static const float kGEAPopoverSpaceBetweenTailAndContent = -1.0f; //Tail overlaps the content 3px
static const float kGEAPopoverIconLeftPadding = 13.0f;
static const float kGEAPopoverTextLeftPadding = 13.0f;

// Alphas
static const float kGEAPopoverDarkContainerAlpha = 0.60f;

// Rounded corners and decorators
static const float kGEAPopoverContentCornerRadius = 3.0f;

// Font
static NSString * const kGEAPopoverFont = @"AvenirNext-Regular";
static const float kGEAPopoverFontSize = 16.0f;

// Reuse identifier string
static NSString * const kReuseIdentifier = @"GEAPopoverCellID";
static NSString * const kReuseIdentifierLast = @"GEAPopoverLastCellID";


@interface GEAPopoverViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) UIBarButtonItem *barButtonItem;
@property (retain, nonatomic) UIView *contentContainer;
@property (retain, nonatomic) UIView *darkContainer;
@property (retain, nonatomic) UIImageView *tailImage;
//@property (retain, nonatomic) UIImageView *contentContainerBackground;
@property (atomic) GEAAlignment contentAlignment;
@property (atomic) float tailCenterX;
@property (atomic) float totalRows;

- (void)presentDarkContainerInView:(UIView *)v animated:(bool)a;
- (void)presentContentContainerInView:(UIView *)v animated:(bool)a;
- (void)presentTailInView:(UIView *)v animated:(bool)a;
- (void)presentTableViewAnimated:(bool)a;
- (void)dismissPopoverDefault;
- (float)getPopoverTailCenterOfBarButton:(UIBarButtonItem *)buttonItem;

@end

@implementation GEAPopoverViewController

- (id)initWithDelegate:(id<GEAPopoverViewControllerDelegate>)delegate_ withBarButton:(UIBarButtonItem *)buttonItem alignedTo:(GEAAlignment)align
{
    if(self = [super init])
    {
        self.isPresented = false;
        self.contentContainer = nil;
        self.darkContainer = nil;
        self.tableView = nil;
        self.tailImage = nil;
        self.delegate = delegate_;
        self.barButtonItem = buttonItem;
        self.contentAlignment = align;
        self.totalRows = 0;
        self.tailCenterX = [self getPopoverTailCenterOfBarButton:self.barButtonItem]; // This is the X axis position where the tail must be placed
    }

    return self;
}

- (void)presentPopoverInView:(UIView *)v animated:(bool)a
{
    [self presentDarkContainerInView:v animated:a];
    [self presentContentContainerInView:v animated:a];
    [self presentTailInView:v animated:a];
    [self presentTableViewAnimated:a];

    self.isPresented = true;
}

- (void)presentDarkContainerInView:(UIView *)v animated:(bool)a
{
    int verticalPosition = kGEAiPhoneNavigationBarHeight; // Assuming that the navigation bar is shown

    // Check if status bar is shown
    if (![UIApplication sharedApplication].statusBarHidden)
        verticalPosition+=kGEAiPhoneStatusBarHeight;

    if(self.darkContainer)
        [self.darkContainer removeFromSuperview];
    self.darkContainer = [[UIView alloc] initWithFrame:CGRectMake(0, verticalPosition, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - verticalPosition)];
    [self.darkContainer setBackgroundColor:[UIColor darkGrayColor]];
    [self.darkContainer setAlpha:kGEAPopoverDarkContainerAlpha];
    [self.darkContainer setUserInteractionEnabled:YES];
    [v addSubview:self.darkContainer];

    UITapGestureRecognizer *touchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopoverDefault)];
    [touchGesture setNumberOfTapsRequired:1];
    [touchGesture setNumberOfTouchesRequired:1];
    [self.darkContainer addGestureRecognizer:touchGesture];
}

- (void)presentTailInView:(UIView *)v animated:(bool)a
{
    if(self.tailImage)
        [self.tailImage removeFromSuperview];
    self.tailImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.tailCenterX - (kGEAPopoverTailWidth/2.0f), kGEAPopoverContentVerticalPadding - kGEAPopoverTailHeight, kGEAPopoverTailWidth, kGEAPopoverTailHeight)];
    [self.tailImage setImage:[UIImage imageNamed:@"popover-tail"]];
    [self.tailImage setBackgroundColor:[UIColor clearColor]];
    [v addSubview:self.tailImage];
}

- (void)presentContentContainerInView:(UIView *)v animated:(bool)a
{
    if(self.contentContainer)
        [self.contentContainer removeFromSuperview];

    if(self.contentAlignment == GEAPopoverAlignmentLeft)
    {
        self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(kGEAPopoverContentHorizontalPadding, kGEAPopoverContentVerticalPadding + kGEAPopoverSpaceBetweenTailAndContent, kGEAPopoverContentWidth, kGEAPopoverMaxContentHeight)];
        [self.contentContainer setBackgroundColor:[UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0]];
        [v addSubview:self.contentContainer];
    }
    else if(self.contentAlignment == GEAPopoverAlignmentRight)
    {
        self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - kGEAPopoverContentWidth - kGEAPopoverContentHorizontalPadding, kGEAPopoverContentVerticalPadding + kGEAPopoverSpaceBetweenTailAndContent, kGEAPopoverContentWidth, kGEAPopoverMaxContentHeight)];
        [self.contentContainer setBackgroundColor:[UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0]];
        [v addSubview:self.contentContainer];
    }
    else if(self.contentAlignment == GEAPopoverAlignmentCenter)
    {
        self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width/2.0f) - (kGEAPopoverContentWidth/2.0f), kGEAPopoverContentVerticalPadding + kGEAPopoverSpaceBetweenTailAndContent, kGEAPopoverContentWidth, kGEAPopoverMaxContentHeight)];
        [self.contentContainer setBackgroundColor:[UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0]];
        [v addSubview:self.contentContainer];
    }

/*
    self.contentContainerBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kGEAPopoverContentWidth,kGEAPopoverMaxContentHeight)];
    [self.contentContainerBackground setContentMode:UIViewContentModeScaleToFill];

    UIImage *contentContainerBackgroundImage = [[UIImage imageNamed:@"img_popover_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(kGEAPopoverContentVerticalMargin, kGEAPopoverContentVerticalMargin, kGEAPopoverContentVerticalMargin, kGEAPopoverContentVerticalMargin)];
    [self.contentContainerBackground setAutoresizesSubviews:YES];
    [self.contentContainerBackground setImage:contentContainerBackgroundImage];
    [self.contentContainer addSubview:self.contentContainerBackground];
    [self.contentContainer setAutoresizesSubviews:YES];
*/
    //self.contentContainer.layer.masksToBounds = YES;
    self.contentContainer.layer.cornerRadius = kGEAPopoverContentCornerRadius;

    // Set the global shadow
    self.contentContainer.layer.masksToBounds = YES;
    self.contentContainer.clipsToBounds = YES;

}

- (void)presentTableViewAnimated:(bool)a
{
    if(self.tableView)
        [self.tableView removeFromSuperview];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kGEAPopoverContentVerticalMargin, kGEAPopoverContentWidth, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setScrollEnabled:NO];
    [self.tableView setClipsToBounds:YES];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBounces:NO];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.contentContainer addSubview:self.tableView];

    self.tableView.layer.cornerRadius = kGEAPopoverContentCornerRadius;
    self.tableView.layer.masksToBounds = YES;
}

- (void)dismissPopoverDefault
{
    [self dismissPopoverAnimated:YES];
}

- (void)dismissPopoverAnimated:(bool)animated
{
    if(animated)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.tailImage.alpha = 0;
                             self.contentContainer.alpha = 0;
                             self.darkContainer.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [self.tailImage removeFromSuperview];
                             [self.contentContainer removeFromSuperview];
                             [self.darkContainer removeFromSuperview];
                         }];
    }
    else
    {
        [self.tailImage removeFromSuperview];
        [self.contentContainer removeFromSuperview];
        [self.darkContainer removeFromSuperview];
    }

    self.isPresented = false;
}

- (float)getPopoverTailCenterOfBarButton:(UIBarButtonItem *)buttonItem
{
    float button_origin_x;

    UIView *button_view = [buttonItem valueForKey:@"view"];
    CGFloat button_width = button_view ? [button_view frame].size.width : buttonItem.width;

    switch(self.contentAlignment)
    {
        case GEAPopoverAlignmentLeft:   return (kGEAPopoverUIToolbarMargin + (button_width/2.0f));
                                        break;

        case GEAPopoverAlignmentRight:  button_origin_x = [[UIScreen mainScreen] bounds].size.width - button_width - kGEAPopoverUIToolbarMargin;
                                        return (button_origin_x + (button_width/2.0f));
                                        break;

        case GEAPopoverAlignmentCenter: return ([[UIScreen mainScreen] bounds].size.width/2.0f);
                                        break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.totalRows = 0;
    if([self.delegate respondsToSelector:@selector(numberOfRowsInPopoverViewController:)])
        self.totalRows = [self.delegate numberOfRowsInPopoverViewController:self];

    // Set the tableView height
    int tableViewHeight = 0;
    if(self.totalRows>1)    tableViewHeight = ((self.totalRows-1)*kGEAPopoverContentRowHeight) + (kGEAPopoverContentRowHeight-kGEAPopoverContentVerticalMargin);
    else                    tableViewHeight = (self.totalRows-1)*kGEAPopoverContentRowHeight;

    self.tableView.frame = CGRectMake(0, kGEAPopoverContentVerticalMargin, kGEAPopoverContentWidth, tableViewHeight);

    // Set the container view height
    CGRect contentContainerFrame = self.contentContainer.frame;
    contentContainerFrame.size.height = kGEAPopoverContentVerticalMargin + tableViewHeight + kGEAPopoverContentVerticalMargin;
    self.contentContainer.frame = contentContainerFrame;

/*
    CGRect contentContainerBackgroundFrame = self.contentContainerBackground.frame;
    contentContainerBackgroundFrame.size.height = contentContainerFrame.size.height;
    self.contentContainerBackground.frame = contentContainerBackgroundFrame;
*/
    return self.totalRows;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(willSelectRowInPopoverViewController:atRowIndex:)])
        [self.delegate willSelectRowInPopoverViewController:self atRowIndex:indexPath.row];

    [self dismissPopoverDefault];

    return indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    bool lastCell = (indexPath.row == self.totalRows-1);
    NSString *reuseIdentifier = kReuseIdentifier;

    if(lastCell)
        reuseIdentifier = kReuseIdentifierLast;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,kGEAPopoverContentWidth,kGEAPopoverContentRowHeight)];

        if(!lastCell)
        {
            UIImageView *cellSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(0,kGEAPopoverContentRowHeight - kGEAPopoverContentSeparatorHeight, kGEAPopoverContentWidth, kGEAPopoverContentSeparatorHeight)];
            [cellSeparator setImage:[UIImage imageNamed:@"popover-separator"]];
            [cell.contentView addSubview:cellSeparator];
        }

        [cell.contentView setBackgroundColor:[UIColor colorWithRed:111.0/255.0 green:190.0/255.0 blue:226.0/255.0 alpha:1.0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;

        UIView *selectedBackgroundView = [[UIView alloc] init];
        [selectedBackgroundView setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:109.0f/255.0f blue:157.0f/255.0f alpha:1.0f]];
        [cell setSelectedBackgroundView:selectedBackgroundView];

        [cell setClipsToBounds:YES];
    }

    if([self.delegate respondsToSelector:@selector(iconImageInPopoverViewController:atRowIndex:)])
    {
        UIImage *iconImage = [self.delegate iconImageInPopoverViewController:self atRowIndex:indexPath.row];
        int iconVerticalPosition = (kGEAPopoverContentRowHeight/2.0f) - (kGEAPopoverIconHeight/2.0f);
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kGEAPopoverIconLeftPadding, iconVerticalPosition, kGEAPopoverIconWidth, kGEAPopoverIconHeight)];
        [iconImageView setImage:iconImage];
        [cell.contentView addSubview:iconImageView];
    }

    if([self.delegate respondsToSelector:@selector(textInPopoverViewController:atRowIndex:)])
    {
        NSString *text = [self.delegate textInPopoverViewController:self atRowIndex:indexPath.row];
        int textVerticalPosition = (kGEAPopoverContentRowHeight/2.0f) - (kGEAPopoverTextHeight/2.0f);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kGEAPopoverIconLeftPadding + kGEAPopoverIconWidth + kGEAPopoverTextLeftPadding, textVerticalPosition, kGEAPopoverTextWidth, kGEAPopoverTextHeight)];
        textLabel.textAlignment =  UITextAlignmentLeft;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        //textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.font = [UIFont fontWithName:kGEAPopoverFont size:kGEAPopoverFontSize];
        [textLabel setText:text];
        [cell.contentView addSubview:textLabel];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    bool lastCell = (indexPath.row == self.totalRows-1);

    if(lastCell)
            return kGEAPopoverContentRowHeight - kGEAPopoverContentSeparatorHeight;
    else    return kGEAPopoverContentRowHeight;
}

@end
