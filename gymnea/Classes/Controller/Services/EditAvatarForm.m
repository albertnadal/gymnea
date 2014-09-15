//
//  EditAvatarForm.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "EditAvatarForm.h"

@implementation EditAvatarForm

@synthesize avatar;

- (id)initWithPicture:(NSData *)theAvatar
{
    self = [super init];
    if(self)
    {
        [self setAvatar:theAvatar];

        return self;
    }

    return nil;
}

@end
