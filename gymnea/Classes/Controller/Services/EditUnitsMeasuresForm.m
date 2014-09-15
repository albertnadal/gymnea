//
//  EditUnitsMeasuresForm.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "EditUnitsMeasuresForm.h"

@implementation EditUnitsMeasuresForm

@synthesize cm;
@synthesize feet;
@synthesize inch;
@synthesize kilo;
@synthesize lbs;
@synthesize st;
@synthesize st_lbs;
@synthesize unit_length;
@synthesize unit_weight;

- (id)initWithCm:(NSString *)theCm
            feet:(NSString *)theFeet
            inch:(NSString *)theInch
            kilo:(NSString *)theKilo
             lbs:(NSString *)theLbs
              st:(NSString *)theSt
          stLbs:(NSString *)theStLbs
     unit_length:(NSString *)theUnitLength
     unit_weight:(NSString *)theUnitWeight
{
    self = [super init];
    if(self)
    {
        [self setCm:theCm];
        [self setFeet:theFeet];
        [self setInch:theInch];
        [self setKilo:theKilo];
        [self setLbs:theLbs];
        [self setSt:theSt];
        [self setSt_lbs:theStLbs];
        [self setUnit_length:theUnitLength];
        [self setUnit_weight:theUnitWeight];

        return self;
    }

    return nil;
}

@end
