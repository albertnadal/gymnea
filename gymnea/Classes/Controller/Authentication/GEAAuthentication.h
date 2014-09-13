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
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *clientInfoHash;
@property (nonatomic, strong) NSString *clientKey;
@property (nonatomic) BOOL localDataIsInitialized;
@property (nonatomic, strong) NSDate *dateExercisesUpdate;
@property (nonatomic, strong) NSDate *dateWorkoutsUpdate;
@property (nonatomic, strong) NSDate *dateUserPicturesUpdate;
@property (nonatomic, strong) NSDictionary *additionalParameters;

- (id)initWithAuthBaseURL:(NSString *)baseUrl
                userEmail:(NSString *)userEmail
           clientInfoHash:(NSString *)clientInfoHash
                clientKey:(NSString *)clientKey;

@end


@protocol GEAAuthenticationStore <NSObject>

- (void)setAuthentication:(GEAAuthentication *)authentication forIdentifier:(NSString *)identifier;
- (GEAAuthentication *)authenticationForIdentifier:(NSString *)identifier;

@end
