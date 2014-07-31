//
//  BookDetails.m
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "BookDetails.h"


@implementation BookDetails

@synthesize title;
@synthesize ide;
@synthesize image;
@synthesize author;
@synthesize price;

- (id)initWithId:(int)theId
           image:(NSString *)theImage
           title:(NSString *)theTitle
          author:(NSString *)theAuthor
           price:(double)thePrice
{
    self = [super init];
    if(self)
    {
        [self setIde:theId];
        [self setImage:theImage];
        [self setTitle:theTitle];
        [self setAuthor:theAuthor];
        [self setPrice:thePrice];
    }
    
    return self;
}

@end
