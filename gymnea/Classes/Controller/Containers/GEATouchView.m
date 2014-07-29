//
//  GEATouchView.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 29/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//


#import "GEATouchView.h"

@implementation GEATouchView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if ([self pointInside:point withEvent:event]) {
    if (self.touchRedirectionView && self.touchRedirectionView.userInteractionEnabled) {
      CGPoint adjustedPoint = [self convertPoint:point toView:self.touchRedirectionView];
      if ([self.touchRedirectionView pointInside:adjustedPoint withEvent:event]) {
        return [self.touchRedirectionView hitTest:adjustedPoint withEvent:event];
      } else {
        return self.touchRedirectionView;
      }
    } else {
      return self;
    }
  }
  return nil;
}

@end
