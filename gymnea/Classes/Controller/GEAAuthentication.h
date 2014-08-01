//
//  GEAAuthentication.h
//  Gymnea
//
//  Created by Albert Nadal Garriga on 2014-08-01.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GEAAuthentication : NSObject <NSCoding>

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *clientInfoHash;
@property (nonatomic, strong) NSString *clientKey;
@property (nonatomic, strong) NSDictionary *additionalParameters;

- (id)initWithAuthBaseURL:(NSString *)baseUrl
           clientInfoHash:(NSString *)clientInfoHash
                clientKey:(NSString *)clientKey;

@end


@protocol GEAAuthenticationStore <NSObject>

- (void)setAuthentication:(GEAAuthentication *)authentication forIdentifier:(NSString *)identifier;
- (GEAAuthentication *)authenticationForIdentifier:(NSString *)identifier;

@end
