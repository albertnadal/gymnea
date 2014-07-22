//
//  GEALabel.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import "GEALabel.h"

@interface GEALabel ()

- (void)setup;

@end

@implementation GEALabel

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;
  }
  [self setup];
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (!self) {
    return nil;
  }
  [self setup];
  return self;
}

#pragma mark - Getters and setters

- (void)setTextGradient:(CGGradientRef)textGradient {
  if (_textGradient == textGradient) {
    return;
  }
  
  if (_textGradient) {
    CGGradientRelease(_textGradient);
    _textGradient = NULL;
  }
  
  _textGradient = textGradient;
  CGGradientRetain(_textGradient);
  
  [self setNeedsDisplay];
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
  if (_shadowBlur == shadowBlur) {
    return;
  }
  
  _shadowBlur = shadowBlur;
  
  [self setNeedsDisplay];
}

#pragma mark - Drawing method

- (void)drawTextInRect:(CGRect)rect {
  
  if (!self.textGradient) {
    [super drawTextInRect:rect];
    return;
  }
  
  UIImage *textImageMask = nil;
  UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0f);
  [super drawTextInRect:rect];
  textImageMask = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // Clip our context to our text mask and fill with a linear gradient
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  
  // Manually set our shadow since we didn't draw it with our image mask
  CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
  
  CGContextBeginTransparencyLayerWithRect(ctx, rect, NULL);

  // Our image is flipped; flip our coordinates
  CGContextScaleCTM(ctx, 1.0, -1.0);
  CGContextTranslateCTM(ctx, 0, -CGRectGetHeight(self.bounds));
  
  CGContextClipToMask(ctx, rect, textImageMask.CGImage);
  CGContextDrawLinearGradient(ctx, self.textGradient, CGPointMake(0, CGRectGetHeight(rect)), CGPointZero, 0);

  CGContextEndTransparencyLayer(ctx);
  
  CGContextRestoreGState(ctx);
  
}

#pragma mark - Dealloc

- (void)dealloc {
  if (_textGradient) {
    CGGradientRelease(_textGradient);
    _textGradient = NULL;
  }
}

#pragma mark - Private methods

- (void)setup {
  _shadowBlur = 1.0f;
}

@end
