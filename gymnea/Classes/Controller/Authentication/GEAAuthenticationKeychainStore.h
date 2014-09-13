//
//  GEAAuthenticationKeychainStore.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 2014-08-01.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GEAAuthentication.h"

@interface GEAAuthenticationKeychainStore : NSObject <GEAAuthenticationStore>

+ (void)clearAllData;

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;

@end
