//
//  EditUnitsMeasuresForm.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditUnitsMeasuresForm : NSObject

@property (nonatomic, retain) NSString * cm;
@property (nonatomic, retain) NSString * feet;
@property (nonatomic, retain) NSString * inch;
@property (nonatomic, retain) NSString * kilo;
@property (nonatomic, retain) NSString * lbs;
@property (nonatomic, retain) NSString * st;
@property (nonatomic, retain) NSString * st_lbs;
@property (nonatomic, retain) NSString * unit_length;
@property (nonatomic, retain) NSString * unit_weight;

- (id)initWithCm:(NSString *)theCm
            feet:(NSString *)theFeet
            inch:(NSString *)theInch
            kilo:(NSString *)theKilo
             lbs:(NSString *)theLbs
              st:(NSString *)theSt
           stLbs:(NSString *)theStLbs
     unit_length:(NSString *)theUnitLength
     unit_weight:(NSString *)theUnitWeight;

@end
