//
//  GEALabel+Gymnea.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 09/07/14.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import "GEALabel.h"

@interface GEALabel (Gymnea)

- (id)initWithText:(NSString *)theText fontSize:(CGFloat)size frame:(CGRect)frame;
- (id)initWithText:(NSString *)theText fontSize:(CGFloat)size textAlign:(NSTextAlignment)textAlign frame:(CGRect)frame;

@end
