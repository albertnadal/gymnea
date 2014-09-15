//
//  EditAvatarForm.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 15/09/14.
//  Copyright (c) 2013 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditAvatarForm : NSObject

@property (nonatomic, retain) NSData * avatar;

- (id)initWithPicture:(NSData *)theAvatar;

@end
