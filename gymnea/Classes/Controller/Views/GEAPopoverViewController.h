//
//  GEAPopoverViewController.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 27/03/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GEAPopoverAlignmentLeft,
    GEAPopoverAlignmentCenter,
    GEAPopoverAlignmentRight
} GEAAlignment;

@protocol GEAPopoverViewControllerDelegate;

@interface GEAPopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<GEAPopoverViewControllerDelegate>delegate;
@property (atomic) bool isPresented;

- (id)initWithDelegate:(id<GEAPopoverViewControllerDelegate>)delegate_ withBarButton:(UIBarButtonItem *)buttonItem alignedTo:(GEAAlignment)align;
- (void)presentPopoverInView:(UIView *)v animated:(bool)a;
- (void)dismissPopoverAnimated:(bool)animated;

@end

@protocol GEAPopoverViewControllerDelegate <NSObject>

- (NSInteger)numberOfRowsInPopoverViewController:(GEAPopoverViewController *)popover;
- (UIImage *)iconImageInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;
- (NSString *)textInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;
- (void)willSelectRowInPopoverViewController:(GEAPopoverViewController *)popover atRowIndex:(NSInteger)index;

@end
