//
//  EditPersonalProfileForm.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import "EditPersonalProfileForm.h"

@implementation EditPersonalProfileForm

@synthesize firstName;
@synthesize lastName;
@synthesize gender;
@synthesize day;
@synthesize month;
@synthesize year;

- (id)initWithName:(NSString *)theName
          lastName:(NSString *)theLastName
            gender:(NSString *)theGender
               day:(int)theDay
             month:(int)theMonth
              year:(int)theYear
{
    self = [super init];
    if(self)
    {
        [self setFirstName:theName];
        [self setLastName:theLastName];
        [self setGender:theGender];
        [self setDay:theDay];
        [self setMonth:theMonth];
        [self setYear:theYear];

        return self;
    }

    return nil;
}

@end
