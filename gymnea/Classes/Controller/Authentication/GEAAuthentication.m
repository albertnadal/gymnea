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
                userEmail:(NSString *)userEmail
           clientInfoHash:(NSString *)clientInfoHash
                clientKey:(NSString *)clientKey
{
    self = [super init];

    if (self) {

        self.baseUrl = baseUrl;
        self.userEmail = userEmail;
        self.clientInfoHash = clientInfoHash;
        self.clientKey = clientKey;
        self.localDataIsInitialized = FALSE;
        self.dateExercisesUpdate = nil;
        self.dateWorkoutsUpdate = nil;
        self.dateUserPicturesUpdate = nil;

    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

  [aCoder encodeObject:_baseUrl forKey:@"baseUrl"];
  [aCoder encodeObject:_userEmail forKey:@"userEmail"];
  [aCoder encodeObject:_clientInfoHash  forKey:@"clientInfoHash"];
  [aCoder encodeObject:_clientKey forKey:@"clientKey"];

  [aCoder encodeObject:[NSNumber numberWithBool:_localDataIsInitialized] forKey:@"localDataIsInitialized"];

  [aCoder encodeObject:_dateExercisesUpdate forKey:@"dateExercisesUpdate"];
  [aCoder encodeObject:_dateWorkoutsUpdate forKey:@"dateWorkoutsUpdate"];
  [aCoder encodeObject:_dateUserPicturesUpdate forKey:@"dateUserPicturesUpdate"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
  
  self = [super init];
  if (self) {

    self.baseUrl = [aDecoder decodeObjectForKey:@"baseUrl"];
    self.userEmail = [aDecoder decodeObjectForKey:@"userEmail"];
    self.clientInfoHash = [aDecoder decodeObjectForKey:@"clientInfoHash"];
    self.clientKey = [aDecoder decodeObjectForKey:@"clientKey"];
    self.localDataIsInitialized = [(NSNumber *)[aDecoder decodeObjectForKey:@"localDataIsInitialized"] boolValue];

    self.dateExercisesUpdate = [aDecoder decodeObjectForKey:@"dateExercisesUpdate"];
    self.dateWorkoutsUpdate = [aDecoder decodeObjectForKey:@"dateWorkoutsUpdate"];
    self.dateUserPicturesUpdate = [aDecoder decodeObjectForKey:@"dateUserPicturesUpdate"];

  }
  
  return self;  
  
}

- (NSString *)description {

  return [NSString stringWithFormat:@"baseUrl=%@ userEmail=%@ clientInfoHash=%@ clientKey=%@ localDataIsInitialized=%d dateExercisesUpdate=%@ dateWorkoutsUpdate=%@ dateUserPicturesUpdate=%@",
          self.baseUrl,
          self.userEmail,
          self.clientInfoHash,
          self.clientKey,
          self.localDataIsInitialized,
          self.dateExercisesUpdate,
          self.dateWorkoutsUpdate,
          self.dateUserPicturesUpdate];
}

@end
