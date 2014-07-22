//
//  EventDetail.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 10/04/13.
//  Copyright (c) 2014 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventDetail : NSObject

@property (atomic) int eventId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *bannerUrl;
@property (nonatomic, strong) NSString *eventUrl;
@property (atomic) int rating;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (atomic) int minPrice;
@property (atomic) int maxPrice;
@property (atomic) int minimalAge;
@property (nonatomic, strong) NSString *address;
@property (atomic) float latitude;
@property (atomic) float longitude;
@property (nonatomic, strong) NSArray *times;

@end
