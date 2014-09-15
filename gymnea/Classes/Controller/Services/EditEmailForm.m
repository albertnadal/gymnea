//
//  EditEmailForm.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "EditEmailForm.h"

@implementation EditEmailForm

@synthesize email;

- (id)initWithEmail:(NSString *)theEmail
{
    self = [super init];
    if(self)
    {
        [self setEmail:theEmail];

        return self;
    }

    return nil;
}

@end
