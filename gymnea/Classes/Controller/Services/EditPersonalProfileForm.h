//
//  EditPersonalProfileForm.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditPersonalProfileForm : NSObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;

- (id)initWithName:(NSString *)theName
          lastName:(NSString *)theLastName
            gender:(NSString *)theGender
               day:(int)theDay
             month:(int)theMonth
              year:(int)theYear;

@end
