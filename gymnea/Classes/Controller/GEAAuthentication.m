//
//  GEAAuthentication.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 2014-08-01.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import "GEAAuthentication.h"

@implementation GEAAuthentication

- (id)initWithAuthBaseURL:(NSString *)baseUrl
           clientInfoHash:(NSString *)clientInfoHash
                clientKey:(NSString *)clientKey
{
    self = [super init];
    
    if (self) {

        self.baseUrl = baseUrl;
        self.clientInfoHash = clientInfoHash;
        self.clientKey = clientKey;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

  [aCoder encodeObject:_baseUrl forKey:@"baseUrl"];
  [aCoder encodeObject:_clientInfoHash  forKey:@"clientInfoHash"];
  [aCoder encodeObject:_clientKey forKey:@"clientKey"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  
  self = [super init];
  if (self) {

    self.baseUrl = [aDecoder decodeObjectForKey:@"baseUrl"];
    self.clientInfoHash = [aDecoder decodeObjectForKey:@"clientInfoHash"];
    self.clientKey = [aDecoder decodeObjectForKey:@"clientKey"];
  }
  
  return self;  
  
}

- (NSString *)description {

  return [NSString stringWithFormat:@"baseUrl=%@ clientInfoHash=%@ clientKey=%@",
          self.baseUrl,
          self.clientInfoHash,
          self.clientKey];
}

@end