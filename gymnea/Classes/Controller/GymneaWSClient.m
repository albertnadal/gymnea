//
//  GymneaWSClient.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 08/08/14.
//  Copyright (c) 2014 Albert Nadal Garriga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "GymneaWSClient.h"
#import "Reachability.h"
#import "GEAAuthentication.h"
#import "GEAAuthenticationKeychainStore.h"

static const NSString *kWSDomain = @"athlete.gymnea.com";

@interface GymneaWSClient ()
{
    BOOL internetIsReachable;
    Reachability* reach;
}

@property (nonatomic, retain) NSString *sessionId;
@property (nonatomic, retain) Reachability *reach;
@property (nonatomic) BOOL internetIsReachable;

typedef void(^responseCompletionBlock)(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *responseCookies);
typedef void(^responseImageCompletionBlock)(GymneaWSClientRequestStatus success, UIImage *image);

- (void) performAsyncRequest:(NSString *)path
              withDictionary:(NSDictionary *)values
          withAuthentication:(GEAAuthentication *)auth
         withCompletionBlock:(responseCompletionBlock)completionBlock;

- (void)performImageAsyncRequest:(NSString *)path
                  withDictionary:(NSDictionary *)values
              withAuthentication:(GEAAuthentication *)auth
             withCompletionBlock:(responseImageCompletionBlock)completionBlock;

@end

@implementation GymneaWSClient

@synthesize sessionId;
@synthesize internetIsReachable;
@synthesize reach;


+ (GymneaWSClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    static GymneaWSClient *_instance;

    dispatch_once(&onceToken, ^{
        _instance = [[GymneaWSClient alloc] init];
    });

    return _instance;
}

- (id)init
{
    if(self = [super init])
    {
        self.internetIsReachable = TRUE;
        self.reach = [Reachability reachabilityWithHostname:@"www.gymnea.com"];

        __weak GymneaWSClient *wsc = self;

        reach.reachableBlock = ^(Reachability*reach)
        {
            wsc.internetIsReachable = TRUE;
        };

        reach.unreachableBlock = ^(Reachability*reach)
        {
            wsc.internetIsReachable = FALSE;
        };

        [reach startNotifier];

        return self;
    }

    return nil;
}

- (void)signInForUsername:(NSString *)username
              andPassword:(NSString *)password
      withCompletionBlock:(signInCompletionBlock)completionBlock
{
    NSString *requestPath = @"/api/auth";

    [self performAsyncRequest:requestPath
               withDictionary:@{@"username" : username, @"password": password}
           withAuthentication:nil
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              UserInfo *userInfo = nil;

              GymneaSignInWSClientRequestResponse signInStatus = GymneaSignInWSClientRequestError;

              if(success == GymneaWSClientRequestSuccess) {
                  signInStatus = GymneaSignInWSClientRequestSuccess;

                  if([cookies objectForKey:@"uid"] != nil) {
                      GEAAuthentication *authentication = [[GEAAuthentication alloc] initWithAuthBaseURL:[NSString stringWithFormat:@"%@", kWSDomain]
                                                                                               userEmail:username
                                                                                          clientInfoHash:[cookies objectForKey:@"uid"]
                                                                                               clientKey:[cookies objectForKey:@"ukey"]];

                      GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
                      [keychainStore setAuthentication:authentication forIdentifier:@"gymnea"];
                  }

                  userInfo = [UserInfo updateUserInfoWithEmail:username withDictionary:[responseData objectForKey:@"userInfo"]];

                  // Now we make a fake request to update the session id
                  [self requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) { /* Do nothing */ }];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signInStatus, responseData, userInfo);
              });

    }];
}

- (void)signUpWithForm:(SignUpForm *)signUpForm
   withCompletionBlock:(signUpCompletionBlock)completionBlock
{
    NSString *requestPath = @"/api/signup";
    
    [self performAsyncRequest:requestPath
               withDictionary:@{@"firstname" : signUpForm.firstName,
                                @"lastname": signUpForm.lastName,
                                @"email": signUpForm.emailAddress,
                                @"password": signUpForm.password,
                                @"gender": signUpForm.gender,
                                @"day": [NSNumber numberWithInt:signUpForm.day],
                                @"month": [NSNumber numberWithInt:signUpForm.month],
                                @"year": [NSNumber numberWithInt:signUpForm.year],
                                @"weight": [NSNumber numberWithFloat:signUpForm.weight],
                                @"weightIsMetric": [NSNumber numberWithBool:signUpForm.weightIsMetricUnits],
                                @"centimeters": [NSNumber numberWithInt:signUpForm.heightCentimeters],
                                @"foot": [NSNumber numberWithInt:signUpForm.heightFoot],
                                @"inches": [NSNumber numberWithInt:signUpForm.heightInches],
                                @"heightIsMetric": [NSNumber numberWithBool:signUpForm.heightIsMetricUnits],
                                @"wearTracker": [NSNumber numberWithInt:signUpForm.doYouWearActivityTracker],
                                @"goGym": [NSNumber numberWithInt:signUpForm.doYouGoToGym],
                                @"useVideoconference": [NSNumber numberWithInt:signUpForm.areYouFamiliarWithVideoconference],
                                @"fitnessGoal": [NSNumber numberWithInt:signUpForm.fitnessGoal]}
           withAuthentication:nil
          withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

              GymneaSignUpWSClientRequestResponse signUpStatus = GymneaSignUpWSClientRequestError;
              UserInfo *userInfo = nil;

              if(success == GymneaWSClientRequestSuccess) {
                  signUpStatus = GymneaSignUpWSClientRequestSuccess;
                  userInfo = [[UserInfo alloc] init];

                  // Now we make a fake request to update the session id
                  [self requestSessionIdWithCompletionBlock:^(GymneaWSClientRequestStatus success) { /* Do nothing */ }];
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  completionBlock(signUpStatus, responseData, userInfo);
              });

          }];

}

- (void)requestSessionIdWithCompletionBlock:(sessionIdCompletionBlock)completionBlock
{

    if(self.internetIsReachable) {

        NSString *requestPath = @"/api/user/get_user_info";

        GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
        GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

        [self performAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success);
                      }
                  });

              }];

    } else {

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestError);
            }
        });

    }

}

- (void)requestUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if(self.internetIsReachable) {

        // Retrieve data from web service API

        NSString *requestPath = @"/api/user/get_user_info";

        [self performAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  UserInfo *userInfo = nil;
                  NSMutableDictionary *responseMutableData = [[NSMutableDictionary alloc] initWithDictionary:responseData];
                  NSMutableDictionary *userInfoMutableData = [[NSMutableDictionary alloc] initWithDictionary:[responseMutableData objectForKey:@"userInfo"]];

                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current UserInfo register in the DB

                      UserInfo *userInfoFromDB = [UserInfo getUserInfo:[auth userEmail]];
                      if((userInfoFromDB != nil) && (userInfoFromDB.picture != nil)) {
                          // By default user image is downloaded separatelly, so is necessary to keep it in the DB
                          [userInfoMutableData setObject:userInfoFromDB.picture forKey:@"picture"];
                          [responseMutableData setObject:userInfoMutableData forKey:@"userInfo"];
                      }

                      userInfo = [UserInfo updateUserInfoWithEmail:[auth userEmail] withDictionary:userInfoMutableData];

                      AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                      [appDelegate saveContext];
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, responseMutableData, userInfo);
                      }

                  });

              }];

    } else {

        // Retrieve data from DB by using the email address as primary key

        UserInfo *userInfo = [UserInfo getUserInfo:[auth userEmail]];

        GymneaWSClientRequestStatus success = (userInfo == nil) ? GymneaWSClientRequestError : GymneaWSClientRequestSuccess;

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(success, nil, userInfo);
            }
        });

    }
}

- (void)requestUserImageWithCompletionBlock:(userImageCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if(self.internetIsReachable) {

        // Retrieve data from web service API

        NSString *requestPath = @"/photo_user/medium";
        [self performImageAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {

                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the user picture in the DB by using the UserInfo model
                           [UserInfo updateUserPictureWithEmail:[auth userEmail] withImage:image];

                           AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                           [appDelegate saveContext];
                       }

                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(completionBlock != nil) {
                               completionBlock(success, image);
                           }

                       });

                   }];

    } else {

        // Retrieve data from DB by using the email address as primary key

        UserInfo *userInfo = [UserInfo getUserInfo:[auth userEmail]];
        UIImage *image = [UIImage imageWithData:userInfo.picture];

        GymneaWSClientRequestStatus success = ((userInfo == nil) || (image == nil)) ? GymneaWSClientRequestError : GymneaWSClientRequestSuccess;

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(success, image);
            }
        });

    }

}

- (void)requestImageForExercise:(int)exerciseId withSize:(GymneaExerciseImageSize)size withCompletionBlock:(userImageCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    UIImage *image = nil;
    BOOL imageInDB = FALSE;

    // First try to retrieve the picture from the DB
    Exercise *exercise = [Exercise getExerciseInfo:exerciseId];

    if(exercise != nil) {

        if((size == ExerciseImageSizeSmall) && (exercise.photoSmall != nil)) {
            image = [UIImage imageWithData:exercise.photoSmall];
        } else if((size == ExerciseImageSizeMedium) && (exercise.photoMedium != nil)) {
            image = [UIImage imageWithData:exercise.photoMedium];
        }

        if(image != nil) {
            imageInDB = TRUE;

            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock != nil) {
                    completionBlock(GymneaWSClientRequestSuccess, image);
                }
            });

            return;
        }
    }

    if((self.internetIsReachable) && (!imageInDB)) {

        // Retrieve data from web service API

        NSString *requestPath = nil;
        if(size == ExerciseImageSizeSmall) {
            requestPath = [NSString stringWithFormat:@"/photo_exercise/small/male/1/%d", exerciseId];
        } else if(size == ExerciseImageSizeMedium) {
            requestPath = [NSString stringWithFormat:@"/photo_exercise/medium/male/1/%d", exerciseId];
        }

        [self performImageAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {
                       
                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the exercise picture in the DB by using the UserInfo model
                           //exercise
                           if(size == ExerciseImageSizeSmall) {
                               [exercise updateWithPhotoSmall:UIImagePNGRepresentation(image)];
                           } else if(size == ExerciseImageSizeMedium) {
                               [exercise updateWithPhotoMedium:UIImagePNGRepresentation(image)];
                           }

                           AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                           [appDelegate saveContext];
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(completionBlock != nil) {
                               completionBlock(success, image);
                           }
                           
                       });
                       
                   }];
        
    } else if(!imageInDB) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, [UIImage imageNamed:@"exercise-default-thumbnail"]);
            }

        });

    }
}

- (void)requestExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if(self.internetIsReachable) {

        // Retrieve data from web service API

        NSString *requestPath = @"/api/exercises/get_exercises";

        [self performAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  NSMutableArray *exercisesArray = nil;

                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current Exercise register in the DB
                      exercisesArray = [[NSMutableArray alloc] init];

                      for (NSDictionary *exerciseDict in (NSArray *)responseData) {
                          NSLog(@"getExerciseInfo: %d", [[exerciseDict objectForKey:@"id"] intValue]);
                          Exercise *exerciseFromDB = [Exercise getExerciseInfo:[[exerciseDict objectForKey:@"id"] intValue]];

                          if(exerciseFromDB != nil) {

                              // Keep current exercise pictures in the DB
                              [exerciseFromDB updateWithExerciseId:[[exerciseDict objectForKey:@"id"] intValue]
                                                              name:[exerciseDict objectForKey:@"n"]
                                                           isSaved:[[exerciseDict objectForKey:@"s"] boolValue]
                                                       equipmentId:[[exerciseDict objectForKey:@"e"] intValue]
                                                          muscleId:[[exerciseDict objectForKey:@"m"] intValue]
                                                            typeId:[[exerciseDict objectForKey:@"t"] intValue]
                                                           levelId:[[exerciseDict objectForKey:@"l"] intValue]
                                                       photoMedium:[exerciseFromDB photoMedium]
                                                        photoSmall:[exerciseFromDB photoSmall]];

                              //[exerciseFromDB updateModelInDB];

                              //AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                              //[appDelegate saveContext];

                              [exercisesArray addObject:exerciseFromDB];
                          } else {

                              Exercise *exerciseInfo = [Exercise updateExerciseWithId:[[exerciseDict objectForKey:@"id"] intValue] withDictionary:exerciseDict];
                              [exercisesArray addObject:exerciseInfo];
                          }

                      }

                      AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                      [appDelegate saveContext];
                  }

                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, exercisesArray);
                      }

                  });

              }];

    } else {

        NSArray *exercisesList = [Exercise getExercises];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, exercisesList);
            }

        });

    }
}

- (void)requestLocalExercisesWithType:(GymneaExerciseType)exerciseTypeId
                           withMuscle:(GymneaMuscleType)muscleId
                        withEquipment:(GymneaEquipmentType)equipmentId
                            withLevel:(GymneaExerciseLevel)levelId
                             withName:(NSString *)searchText
                  withCompletionBlock:(exercisesCompletionBlock)completionBlock
{
    NSArray *exercisesList = [Exercise getExercisesWithType:exerciseTypeId
                                                 withMuscle:muscleId
                                              withEquipment:equipmentId
                                                  withLevel:levelId
                                                   withName:searchText];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(GymneaWSClientRequestSuccess, exercisesList);
        }
        
    });
}

- (void)performImageAsyncRequest:(NSString *)path
                  withDictionary:(NSDictionary *)values
              withAuthentication:(GEAAuthentication *)auth
             withCompletionBlock:(responseImageCompletionBlock)completionBlock {
    
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request setHTTPShouldHandleCookies:YES];
    
    if(auth != nil) {
        NSLog(@"uid: %@", auth.clientInfoHash);
        NSLog(@"ukey: %@", auth.clientKey);
        NSLog(@"session id: %@", [[GymneaWSClient sharedInstance] sessionId]);
        
        NSDictionary *SessionIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @".gymnea.com", NSHTTPCookieDomain,
                                                   @"/", NSHTTPCookiePath,
                                                   @"gym_gymnea", NSHTTPCookieName,
                                                   [[GymneaWSClient sharedInstance] sessionId], NSHTTPCookieValue,
                                                   nil];
        
        NSHTTPCookie *SessionIDPackagedCookie = [NSHTTPCookie cookieWithProperties:SessionIDCookieProperties];
        
        NSDictionary *UIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"uid", NSHTTPCookieName,
                                             auth.clientInfoHash, NSHTTPCookieValue,
                                             nil];
        
        NSHTTPCookie *UIDPackagedCookie = [NSHTTPCookie cookieWithProperties:UIDCookieProperties];
        
        NSDictionary *UKEYCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @".gymnea.com", NSHTTPCookieDomain,
                                              @"/", NSHTTPCookiePath,
                                              @"ukey", NSHTTPCookieName,
                                              auth.clientKey, NSHTTPCookieValue,
                                              nil];
        
        NSHTTPCookie *UKEYPackagedCookie = [NSHTTPCookie cookieWithProperties:UKEYCookieProperties];
        
        NSMutableArray *cookiesArray = [[NSMutableArray alloc] initWithObjects:UIDPackagedCookie, UKEYPackagedCookie, nil];
        if(SessionIDPackagedCookie != nil) {
            [cookiesArray addObject:SessionIDPackagedCookie];
        }
        
        NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
        [request setAllHTTPHeaderFields:cookies];
    }
    
    NSError *error;
    if(values != nil) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:0 error:&error];
        [request setHTTPBody:postData];
    }


    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        completionBlock(GymneaWSClientRequestSuccess, responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        completionBlock(GymneaWSClientRequestError, nil);

    }];

    [requestOperation start];

}

- (void)performAsyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth
        withCompletionBlock:(responseCompletionBlock)completionBlock {

    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPShouldHandleCookies:YES];

    if(auth != nil) {
        NSLog(@"uid: %@", auth.clientInfoHash);
        NSLog(@"ukey: %@", auth.clientKey);
        NSLog(@"session id: %@", [[GymneaWSClient sharedInstance] sessionId]);

        NSDictionary *SessionIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"gym_gymnea", NSHTTPCookieName,
                                             [[GymneaWSClient sharedInstance] sessionId], NSHTTPCookieValue,
                                             nil];

        NSHTTPCookie *SessionIDPackagedCookie = [NSHTTPCookie cookieWithProperties:SessionIDCookieProperties];

        NSDictionary *UIDCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @".gymnea.com", NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"uid", NSHTTPCookieName,
                                    auth.clientInfoHash, NSHTTPCookieValue,
                                    nil];

        NSHTTPCookie *UIDPackagedCookie = [NSHTTPCookie cookieWithProperties:UIDCookieProperties];

        NSDictionary *UKEYCookieProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @".gymnea.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             @"ukey", NSHTTPCookieName,
                                             auth.clientKey, NSHTTPCookieValue,
                                             nil];
        
        NSHTTPCookie *UKEYPackagedCookie = [NSHTTPCookie cookieWithProperties:UKEYCookieProperties];

        NSMutableArray *cookiesArray = [[NSMutableArray alloc] initWithObjects:UIDPackagedCookie, UKEYPackagedCookie, nil];
        if(SessionIDPackagedCookie != nil) {
            [cookiesArray addObject:SessionIDPackagedCookie];
        }

        NSDictionary *cookies = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
        [request setAllHTTPHeaderFields:cookies];
    }

    NSError *error;
    if(values != nil) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:0 error:&error];
        [request setHTTPBody:postData];
    }

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];


    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *responseData, NSURLResponse *urlResponse, NSError *error) {

                                                        GymneaWSClientRequestStatus success = GymneaWSClientRequestError;
                                                        NSHTTPURLResponse *response = (NSHTTPURLResponse*)urlResponse;

                                                        NSInteger responseCode = response.statusCode;
                                                        NSDictionary *results = nil;
                                                        if(error == nil && ((responseCode/100)==2))
                                                        {
                                                            if(responseData != nil)
                                                            {
                                                                results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                                                                if(results != nil) {
                                                                    success = GymneaWSClientRequestSuccess;
                                                                }
                                                            }
                                                        }

                                                        NSArray *cookiesArray =[[NSArray alloc]init];
                                                        cookiesArray = [NSHTTPCookie
                                                                   cookiesWithResponseHeaderFields:[response allHeaderFields]
                                                                   forURL:[NSURL URLWithString:@""]];

                                                        NSMutableDictionary *cookies = [[NSMutableDictionary alloc] init];
                                                        for(NSHTTPCookie *cookie in cookiesArray) {
                                                            [cookies setObject:[cookie valueForKey:@"value"] forKey:[cookie valueForKey:@"name"]];
                                                        }

                                                        if([cookies objectForKey:@"gym_gymnea"] != nil) {
                                                            // Update the session_id value and save in the GymneaWSClient singleton instance
                                                            [[GymneaWSClient sharedInstance] setSessionId:[cookies objectForKey:@"gym_gymnea"]];
                                                        }

                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if(completionBlock != nil) {
                                                                completionBlock(success, (NSDictionary *)results, cookies);
                                                            }
                                                            
                                                        });

                                                    }];

    [sessionDataTask resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        if([challenge.protectionSpace.host isEqualToString:@"athlete.gymnea.com"]){
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
        }
    }
}

@end
