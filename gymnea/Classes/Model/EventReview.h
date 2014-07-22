//
//  EventReview.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 11/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventReview : NSObject

@property (atomic) int order;
@property (nonatomic, retain) NSString *title;
@property (atomic) int rating;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *text;

@end
