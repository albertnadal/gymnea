//
//  BookDetails.h
//  GoldenGekkoExercice
//
//  Created by Albert Nadal Garriga on 17/01/13.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookDetails : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic) int ide;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * author;
@property (nonatomic) double price;

- (id)initWithId:(int)theId
           image:(NSString *)theImage
           title:(NSString *)theTitle
          author:(NSString *)theAuthor
           price:(double)thePrice;

@end
