//
//  GEALabel+Gymnea.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import "GEALabel+Gymnea.h"
#import <QuartzCore/QuartzCore.h>

@implementation GEALabel (Gymnea)

- (id)initWithText:(NSString *)theText fontSize:(CGFloat)size frame:(CGRect)frame {
  return [self initWithText:theText fontSize:size textAlign:NSTextAlignmentCenter frame:frame];
}

- (id)initWithText:(NSString *)theText fontSize:(CGFloat)size textAlign:(NSTextAlignment)textAlign frame:(CGRect)frame {
  if(self = [self initWithFrame:frame]) {
    CGFloat locations[3];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:3];
    [colors addObject:(id)([UIColor colorWithRed:7.0/255.0 green:154.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor)];
    locations[0] = 0.0;
    [colors addObject:(id)([UIColor colorWithRed:11.0f/255.0f green:167.0f/255.0f blue:221.0f/255.0f alpha:1.0].CGColor)];
    locations[1] = 0.5;
    [colors addObject:(id)([UIColor colorWithRed:27.0/255.0 green:205.0/255.0 blue:255.0/255.0 alpha:0.15].CGColor)];
    locations[2] = 1.0;
    
    CGGradientRef goldenGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
    CGColorSpaceRelease(space);
    
    [self setText:theText];
    [self setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:size]];
    [self setTextColor:[UIColor whiteColor]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTextAlignment:textAlign];
    [self setShadowBlur:0.1f];
    [self setTextGradient:goldenGradient];

    [self.layer setMasksToBounds:NO];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0,1.0);
    self.layer.shadowRadius = 1.6f;
    self.layer.shadowOpacity = 0.8;

  }
  
  return self;
}

@end
