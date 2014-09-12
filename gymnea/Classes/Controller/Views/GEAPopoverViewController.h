//
//  GEAPopoverViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/03/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

// Sizes
static const float kGEAPopoverContentWidth = 188.0f; //220.0f
static const float kGEAPopoverContentRowHeight = 44.0f;
static const float kGEAPopoverContentSeparatorHeight = 2.0f;
static const float kGEAPopoverMaxContentHeight = 350.0f;
static const float kGEAPopoverTailWidth = 23.0f;
static const float kGEAPopoverTailHeight = 13.0f;
static const float kGEAPopoverIconWidth = 20.0f;
static const float kGEAPopoverIconHeight = 20.0f;
static const float kGEAPopoverTextWidth =  140.0f; //172.0f;
static const float kGEAPopoverTextHeight = 20.0f;

typedef enum {
    GEAPopoverAlignmentLeft,
    GEAPopoverAlignmentCenter,
    GEAPopoverAlignmentRight
} GEAAlignment;

@protocol GEAPopoverViewControllerDelegate;

@interface GEAPopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<GEAPopoverViewControllerDelegate>delegate;
@property (atomic) bool isPresented;
@property (atomic) float minWidth;

- (id)initWithDelegate:(id<GEAPopoverViewControllerDelegate>)delegate_ withBarButton:(UIBarButtonItem *)buttonItem alignedTo:(GEAAlignment)align;
- (id)initWithDelegate:(id<GEAPopoverViewControllerDelegate>)delegate_ withBarButton:(UIBarButtonItem *)buttonItem alignedTo:(GEAAlignment)align withWidth:(float)minWidth;
- (void)presentPopoverInView:(UIView *)v animated:(bool)a;
- (void)dismissPopoverAnimated:(bool)animated;

@end

@protocol GEAPopoverViewControllerDelegate <NSObject>

- (NSInteger)numberOfRowsInPopoverViewController:(GEAPopoverViewController *)popover;
- (UIImage *)iconImageInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;
- (NSString *)textInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;
- (void)willSelectRowInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;

@end
