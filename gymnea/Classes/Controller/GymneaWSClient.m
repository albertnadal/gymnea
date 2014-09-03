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
typedef void(^responseVideoCompletionBlock)(GymneaWSClientRequestStatus success, NSData *video);
typedef void(^responsePDFCompletionBlock)(GymneaWSClientRequestStatus success, NSData *pdf);

- (void)performPOSTAsyncRequest:(NSString *)path
                 withDictionary:(NSDictionary *)values
             withAuthentication:(GEAAuthentication *)auth
            withCompletionBlock:(responseCompletionBlock)completionBlock;

- (void)performPUTAsyncRequest:(NSString *)path
                withDictionary:(NSDictionary *)values
            withAuthentication:(GEAAuthentication *)auth
           withCompletionBlock:(responseCompletionBlock)completionBlock;

- (void)performAsyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth
                 withMethod:(NSString *)method
        withCompletionBlock:(responseCompletionBlock)completionBlock;

- (void)performImageAsyncRequest:(NSString *)path
                  withDictionary:(NSDictionary *)values
              withAuthentication:(GEAAuthentication *)auth
             withCompletionBlock:(responseImageCompletionBlock)completionBlock;

- (void)performVideoAsyncRequest:(NSString *)path
                  withDictionary:(NSDictionary *)values
              withAuthentication:(GEAAuthentication *)auth
             withCompletionBlock:(responseVideoCompletionBlock)completionBlock;

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

    [self performPOSTAsyncRequest:requestPath
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
    
    [self performPOSTAsyncRequest:requestPath
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

        [self performPOSTAsyncRequest:requestPath
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

        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  //NSLog(@"USER INFO RESPONSE DATA: %@", responseData);

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

                      // Send notification to reload the user current workout view
                      [[NSNotificationCenter defaultCenter] postNotificationName:GEANotificationUserInfoUpdated object:nil userInfo:nil];

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

- (void)requestLocalUserInfoWithCompletionBlock:(userInfoCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    // Retrieve data from DB by using the email address as primary key
    UserInfo *userInfo = [UserInfo getUserInfo:[auth userEmail]];
    
    GymneaWSClientRequestStatus success = (userInfo == nil) ? GymneaWSClientRequestError : GymneaWSClientRequestSuccess;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(success, nil, userInfo);
        }
    });
}

- (UserInfo *)requestLocalUserInfo
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    // Retrieve data from DB by using the email address as primary key
    return [UserInfo getUserInfo:[auth userEmail]];
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

- (void)requestImageForExercise:(int)exerciseId
                       withSize:(GymneaExerciseImageSize)size
                     withGender:(GymneaExerciseImageGender)gender
                      withOrder:(GymneaExerciseImageOrder)order
            withCompletionBlock:(userImageCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    UIImage *image = nil;
    BOOL imageInDB = FALSE;

    // First try to retrieve the picture from the DB
    Exercise *exercise = [Exercise getExerciseInfo:exerciseId];
    ExerciseDetail *exerciseDetail = [ExerciseDetail getExerciseDetailInfo:exerciseId];

    if(exercise != nil) {

        if((gender == ExerciseImageMale) && (order == ExerciseImageFirst)) {

            if((size == ExerciseImageSizeSmall) && (exercise.photoSmall != nil)) {
                image = [UIImage imageWithData:exercise.photoSmall];
            } else if((size == ExerciseImageSizeMedium) && (exercise.photoMedium != nil)) {
                image = [UIImage imageWithData:exercise.photoMedium];
            }

        } else if((gender == ExerciseImageMale) && (order == ExerciseImageSecond)) {

            if((size == ExerciseImageSizeSmall) && (exerciseDetail.photoMaleSmallSecond != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoMaleSmallSecond];
            } else if((size == ExerciseImageSizeMedium) && (exerciseDetail.photoMaleMediumSecond != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoMaleMediumSecond];
            }

        } else if((gender == ExerciseImageFemale) && (order == ExerciseImageFirst)) {

            if((size == ExerciseImageSizeSmall) && (exerciseDetail.photoFemaleSmallFirst != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoFemaleSmallFirst];
            } else if((size == ExerciseImageSizeMedium) && (exerciseDetail.photoFemaleMediumFirst != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoFemaleMediumFirst];
            }

        } else if((gender == ExerciseImageFemale) && (order == ExerciseImageSecond)) {
            
            if((size == ExerciseImageSizeSmall) && (exerciseDetail.photoFemaleSmallSecond != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoFemaleSmallSecond];
            } else if((size == ExerciseImageSizeMedium) && (exerciseDetail.photoFemaleMediumSecond != nil)) {
                image = [UIImage imageWithData:exerciseDetail.photoFemaleMediumSecond];
            }
            
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

        NSString *genderUrlParam = @"";

        if(gender == ExerciseImageMale) {
            genderUrlParam = @"male";
        } else if(gender == ExerciseImageFemale) {
            genderUrlParam = @"female";
        }

        NSString *requestPath = nil;
        if(size == ExerciseImageSizeSmall) {
            requestPath = [NSString stringWithFormat:@"/photo_exercise/small/%@/%d/%d", genderUrlParam, order, exerciseId];
        } else if(size == ExerciseImageSizeMedium) {
            requestPath = [NSString stringWithFormat:@"/photo_exercise/medium/%@/%d/%d", genderUrlParam, order, exerciseId];
        }

        [self performImageAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {

                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the exercise picture in the DB by using the UserInfo model

                           if((gender == ExerciseImageMale) && (order == ExerciseImageFirst)) {

                               if(size == ExerciseImageSizeSmall) {
                                   [exercise updateWithPhotoSmall:UIImagePNGRepresentation(image)];
                               } else if(size == ExerciseImageSizeMedium) {
                                   [exercise updateWithPhotoMedium:UIImagePNGRepresentation(image)];
                               }

                           } else if((gender == ExerciseImageMale) && (order == ExerciseImageSecond)) {
                               
                               if(size == ExerciseImageSizeSmall) {
                                   [exerciseDetail updateWithPhotoMaleSmallSecond:UIImagePNGRepresentation(image)];
                               } else if(size == ExerciseImageSizeMedium) {
                                   [exerciseDetail updateWithPhotoMaleMediumSecond:UIImagePNGRepresentation(image)];
                               }
                               
                           } else if(gender == ExerciseImageFemale) {

                               if(size == ExerciseImageSizeSmall) {
                                   [exerciseDetail updateWithPhotoFemaleSmall:UIImagePNGRepresentation(image) withOrder:order];
                               } else if(size == ExerciseImageSizeMedium) {
                                   [exerciseDetail updateWithPhotoFemaleMedium:UIImagePNGRepresentation(image) withOrder:order];
                               }

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
                completionBlock(GymneaWSClientRequestSuccess, nil);
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

        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  NSMutableArray *exercisesArray = nil;

                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current Exercise register in the DB
                      exercisesArray = [[NSMutableArray alloc] init];

                      for (NSDictionary *exerciseDict in (NSArray *)responseData) {
                          //NSLog(@"getExerciseInfo: %d", [[exerciseDict objectForKey:@"id"] intValue]);
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

- (void)requestSavedExercisesWithCompletionBlock:(exercisesCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {
        
        // Retrieve data from web service API
        
        NSString *requestPath = @"/api/saved_exercises/get_exercises";
        
        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  NSMutableArray *exercisesArray = nil;
                  
                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current Exercise register in the DB
                      exercisesArray = [[NSMutableArray alloc] init];

                      for (NSDictionary *exerciseDict in (NSArray *)responseData) {
                          //NSLog(@"getExerciseInfo: %d", [[exerciseDict objectForKey:@"id"] intValue]);
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
        
        NSArray *exercisesList = [Exercise getSavedExercises];
        
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

- (void)requestLocalExercisesWithType:(GymneaExerciseType)exerciseTypeId
                           withMuscle:(GymneaMuscleType)muscleId
                        withEquipment:(GymneaEquipmentType)equipmentId
                            withLevel:(GymneaExerciseLevel)levelId
                             withName:(NSString *)searchText
                      withExerciseIds:(NSArray *)exerciseIds
                  withCompletionBlock:(exercisesCompletionBlock)completionBlock
{
    NSArray *exercisesList = [Exercise getExercisesWithType:exerciseTypeId
                                                 withMuscle:muscleId
                                              withEquipment:equipmentId
                                                  withLevel:levelId
                                                   withName:searchText
                                            withExerciseIds:exerciseIds];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(GymneaWSClientRequestSuccess, exercisesList);
        }
        
    });
}

- (void)requestLocalSavedExercisesWithType:(GymneaExerciseType)exerciseTypeId
                                withMuscle:(GymneaMuscleType)muscleId
                             withEquipment:(GymneaEquipmentType)equipmentId
                                 withLevel:(GymneaExerciseLevel)levelId
                                  withName:(NSString *)searchText
                       withCompletionBlock:(exercisesCompletionBlock)completionBlock
{
    NSArray *exercisesList = [Exercise getSavedExercisesWithType:exerciseTypeId
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

- (void)requestExerciseDetailWithExercise:(Exercise *)exercise
                      withCompletionBlock:(exerciseDetailCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {

        // Retrieve data from web service API
        NSString *requestPath = [NSString stringWithFormat:@"/api/exercise/get_exercise/%d", [exercise exerciseId]];

        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  ExerciseDetail *exerciseDetail = nil;

                  if(success == GymneaWSClientRequestSuccess) {

                          NSMutableDictionary *exerciseDetailsDict = [[NSMutableDictionary alloc] initWithDictionary:[responseData objectForKey:@"exerciseDetails"]];
                          [exerciseDetailsDict setObject:[NSNumber numberWithInt:[exercise exerciseId]] forKey:@"id"];

                          exerciseDetail = [ExerciseDetail getExerciseDetailInfo:[exercise exerciseId]];
                          
                          if(exerciseDetail != nil) {
                              
                              // Keep current exercise pictures in the DB
                              [exerciseDetail updateWithExerciseId:[exercise exerciseId]
                                                          bodyZone:[exerciseDetailsDict objectForKey:@"bodyZone"]
                                                           isSport:[exerciseDetailsDict objectForKey:@"isSport"]
                                                             force:[exerciseDetailsDict objectForKey:@"force"]
                                                             guide:[exerciseDetailsDict objectForKey:@"guide"]
                                                 photoFemaleMedium:[exerciseDetail photoFemaleMediumFirst]
                                                  photoFemaleSmall:[exerciseDetail photoFemaleSmallFirst]
                                                         videoMale:[exerciseDetail videoMale]
                                                       videoFemale:[exerciseDetail videoFemale]
                                                         videoLoop:[exerciseDetail videoLoop]];

                          } else {
                              exerciseDetail = [ExerciseDetail updateExerciseWithId:[exercise exerciseId] withDictionary:exerciseDetailsDict];
                          }

                          AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                          [appDelegate saveContext];
                      
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, exerciseDetail);
                      }
                      
                  });

              }];
    } else {

        ExerciseDetail *exerciseDetail = [ExerciseDetail getExerciseDetailInfo:[exercise exerciseId]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, exerciseDetail);
            }
            
        });

    }

}

- (void)requestExerciseVideoLoopWithExercise:(Exercise *)exercise
                         withCompletionBlock:(exerciseVideoLoopCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    ExerciseDetail *exerciseDetail = [ExerciseDetail getExerciseDetailInfo:exercise.exerciseId];

    if(self.internetIsReachable) {

        // Retrieve data from web service API
        
        NSString *requestPath = [NSString stringWithFormat:@"/video_loop/%d", exercise.exerciseId];
        [self performVideoAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, NSData *video) {

                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the exercise loop video in the DB by using the ExerciseDetail model
                           if(exerciseDetail) {
                               [exerciseDetail updateWithVideoLoop:video];
                           }

                           AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                           [appDelegate saveContext];
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(completionBlock != nil) {
                               completionBlock(success, video);
                           }
                           
                       });

        }];

    } else {
        
        // Retrieve data from DB
        GymneaWSClientRequestStatus success = ((exerciseDetail == nil) || (exerciseDetail.videoLoop == nil)) ? GymneaWSClientRequestError : GymneaWSClientRequestSuccess;

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(success, exerciseDetail.videoLoop);
            }
        });
        
    }
}

- (void)requestWorkoutsWithCompletionBlock:(workoutsCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {
        
        // Retrieve data from web service API
        
        NSString *requestPath = @"/api/workouts_directory/get_workouts";
        
        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {
                  
                  NSMutableArray *workoutsArray = nil;
                  
                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current Workout register in the DB
                      workoutsArray = [[NSMutableArray alloc] init];
                      
                      for (NSDictionary *workoutDict in (NSArray *)responseData) {
                          //NSLog(@"getWorkoutInfo: %d", [[workoutDict objectForKey:@"id"] intValue]);
                          Workout *workoutFromDB = [Workout getWorkoutInfo:[[workoutDict objectForKey:@"id"] intValue]];
                          
                          if(workoutFromDB != nil) {
                              
                              // Keep current workout pictures in the DB
                              [workoutFromDB updateWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
                                                            name:[workoutDict objectForKey:@"n"]
                                                         isSaved:[[workoutDict objectForKey:@"s"] boolValue]
                                                       frequency:[[workoutDict objectForKey:@"f"] intValue]
                                                          typeId:[[workoutDict objectForKey:@"t"] intValue]
                                                         levelId:[[workoutDict objectForKey:@"l"] intValue]
                                                     photoMedium:[workoutFromDB photoMedium]
                                                      photoSmall:[workoutFromDB photoSmall]];

                              [workoutsArray addObject:workoutFromDB];
                          } else {
                              
                              Workout *workoutInfo = [Workout updateWorkoutWithId:[[workoutDict objectForKey:@"id"] intValue] withDictionary:workoutDict];
                              [workoutsArray addObject:workoutInfo];
                          }
                          
                      }
                      
                      AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                      [appDelegate saveContext];
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, workoutsArray);
                      }
                      
                  });
                  
              }];
        
    } else {
        
        NSArray *workoutsList = [Workout getWorkouts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, workoutsList);
            }
            
        });
        
    }
}

- (void)requestSavedWorkoutsWithCompletionBlock:(workoutsCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {
        
        // Retrieve data from web service API

        NSString *requestPath = @"/api/saved_workouts/get_workouts";

        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {
                  
                  NSMutableArray *workoutsArray = nil;
                  
                  if(success == GymneaWSClientRequestSuccess) {
                      // Insert or update the current Workout register in the DB
                      workoutsArray = [[NSMutableArray alloc] init];
                      
                      for (NSDictionary *workoutDict in (NSArray *)responseData) {
                          //NSLog(@"getWorkoutInfo: %d", [[workoutDict objectForKey:@"id"] intValue]);
                          Workout *workoutFromDB = [Workout getWorkoutInfo:[[workoutDict objectForKey:@"id"] intValue]];
                          
                          if(workoutFromDB != nil) {
                              
                              // Keep current workout pictures in the DB
                              [workoutFromDB updateWithWorkoutId:[[workoutDict objectForKey:@"id"] intValue]
                                                            name:[workoutDict objectForKey:@"n"]
                                                         isSaved:[[workoutDict objectForKey:@"s"] boolValue]
                                                       frequency:[[workoutDict objectForKey:@"f"] intValue]
                                                          typeId:[[workoutDict objectForKey:@"t"] intValue]
                                                         levelId:[[workoutDict objectForKey:@"l"] intValue]
                                                     photoMedium:[workoutFromDB photoMedium]
                                                      photoSmall:[workoutFromDB photoSmall]];
                              
                              [workoutsArray addObject:workoutFromDB];
                          } else {
                              
                              Workout *workoutInfo = [Workout updateWorkoutWithId:[[workoutDict objectForKey:@"id"] intValue] withDictionary:workoutDict];
                              [workoutsArray addObject:workoutInfo];
                          }
                          
                      }
                      
                      AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                      [appDelegate saveContext];
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, workoutsArray);
                      }
                      
                  });
                  
              }];
        
    } else {
        
        NSArray *workoutsList = [Workout getSavedWorkouts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, workoutsList);
            }
            
        });
        
    }
}

- (void)requestLocalWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                       withFrequency:(int)frequence
                           withLevel:(GymneaWorkoutLevel)levelId
                            withName:(NSString *)searchText
                 withCompletionBlock:(workoutsCompletionBlock)completionBlock
{
    NSArray *workoutsList = [Workout getWorkoutsWithType:workoutTypeId
                                           withFrequency:frequence
                                               withLevel:levelId
                                                withName:searchText];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(GymneaWSClientRequestSuccess, workoutsList);
        }

    });
}

- (void)requestLocalSavedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                            withFrequency:(int)frequence
                                withLevel:(GymneaWorkoutLevel)levelId
                                 withName:(NSString *)searchText
                      withCompletionBlock:(workoutsCompletionBlock)completionBlock
{
    NSArray *workoutsList = [Workout getSavedWorkoutsWithType:workoutTypeId
                                                withFrequency:frequence
                                                    withLevel:levelId
                                                     withName:searchText];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(GymneaWSClientRequestSuccess, workoutsList);
        }
        
    });
}

- (void)requestLocalDownloadedWorkoutsWithType:(GymneaWorkoutType)workoutTypeId
                                 withFrequency:(int)frequence
                                     withLevel:(GymneaWorkoutLevel)levelId
                                      withName:(NSString *)searchText
                           withCompletionBlock:(workoutsCompletionBlock)completionBlock
{
    NSArray *workoutsList = [Workout getDownloadedWorkoutsWithType:workoutTypeId
                                                     withFrequency:frequence
                                                         withLevel:levelId
                                                          withName:searchText];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(completionBlock != nil) {
            completionBlock(GymneaWSClientRequestSuccess, workoutsList);
        }
        
    });
}

- (void)requestImageForWorkout:(int)workoutId
                      withSize:(GymneaWorkoutImageSize)size
           withCompletionBlock:(userImageCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    UIImage *image = nil;
    BOOL imageInDB = FALSE;
    
    // First try to retrieve the picture from the DB
    Workout *workout = [Workout getWorkoutInfo:workoutId];

    if(workout != nil) {

        if((size == WorkoutImageSizeSmall) && (workout.photoSmall != nil)) {
            image = [UIImage imageWithData:workout.photoSmall];
        } else if((size == WorkoutImageSizeMedium) && (workout.photoMedium != nil)) {
            image = [UIImage imageWithData:workout.photoMedium];
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
        if(size == WorkoutImageSizeSmall) {
            requestPath = [NSString stringWithFormat:@"/photo_workout/small/%d", workoutId];
        } else if(size == WorkoutImageSizeMedium) {
            requestPath = [NSString stringWithFormat:@"/photo_workout/medium/%d", workoutId];
        }

        [self performImageAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {
                       
                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the exercise picture in the DB by using the UserInfo model
                           
                           if(size == ExerciseImageSizeSmall) {
                               [workout updateWithPhotoSmall:UIImagePNGRepresentation(image)];
                           } else if(size == ExerciseImageSizeMedium) {
                               [workout updateWithPhotoMedium:UIImagePNGRepresentation(image)];
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
                completionBlock(GymneaWSClientRequestSuccess, nil);
            }
            
        });
        
    }
}

- (void)requestWorkoutDetailWithWorkout:(Workout *)workout
                    withCompletionBlock:(workoutDetailCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {
        
        // Retrieve data from web service API
        NSString *requestPath = [NSString stringWithFormat:@"/api/workout/get_workout_info/%d", [workout workoutId]];
        
        [self performPOSTAsyncRequest:requestPath
                   withDictionary:nil
               withAuthentication:auth
              withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                  //NSLog(@"WORKOUT DETAIL RESPONSE DATA: %@", responseData);
                  WorkoutDetail *workoutDetail = nil;
                  
                  if(success == GymneaWSClientRequestSuccess) {
                      
                      NSMutableDictionary *workoutDetailsDict = [[NSMutableDictionary alloc] initWithDictionary:[responseData objectForKey:@"workoutDetails"]];
                      [workoutDetailsDict setObject:[NSNumber numberWithInt:[workout workoutId]] forKey:@"id"];
                      
                      workoutDetail = [WorkoutDetail getWorkoutDetailInfo:[workout workoutId]];
                      
                      if(workoutDetail != nil) {

                          // Keep current exercise pictures in the DB
                          [workoutDetail updateWithWorkoutId:[workout workoutId]
                                             withDescription:[workoutDetailsDict objectForKey:@"description"]
                                                 withMuscles:[workoutDetailsDict objectForKey:@"muscles"]];

                      } else {
                          workoutDetail = [WorkoutDetail updateWorkoutWithId:[workout workoutId] withDictionary:workoutDetailsDict];
                      }

                      // Update the workout days for this workout
                      [workoutDetail updateWithWorkoutDaysDict:[workoutDetailsDict objectForKey:@"workoutDays"]];

                      AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                      [appDelegate saveContext];
                      
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if(completionBlock != nil) {
                          completionBlock(success, workoutDetail);
                      }
                      
                  });
                  
              }];
    } else {
        
        WorkoutDetail *workoutDetail = [WorkoutDetail getWorkoutDetailInfo:[workout workoutId]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, workoutDetail);
            }
            
        });
        
    }

}

- (void)requestWorkoutPDFWithWorkout:(Workout *)workout
                 withCompletionBlock:(workoutPDFCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    if(self.internetIsReachable) {

        // Retrieve PDF from web service API
        NSString *requestPath = [NSString stringWithFormat:@"/api/workout/download_workout_pdf/%d", workout.workoutId];

        [self performPDFAsyncRequest:requestPath
                      withDictionary:nil
                  withAuthentication:auth
                 withCompletionBlock:^(GymneaWSClientRequestStatus success, NSData *pdf) {

                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(completionBlock != nil) {
                               completionBlock(success, pdf);
                           }

                       });

                   }];

    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestError, nil);
            }
            
        });
        
    }

}

- (void)setUserCurrentWorkoutWithWorkout:(Workout *)workout
                     withCompletionBlock:(currentWorkoutCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];

    UserInfo *userInfoFromDB = [UserInfo getUserInfo:[auth userEmail]];
    if(userInfoFromDB != nil) {
        [userInfoFromDB setCurrentWorkoutId:workout.workoutId];
    }

    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];


    if(self.internetIsReachable) {
        
        NSString *requestPath = [NSString stringWithFormat:@"/api/workout/set_current_generic_workout/%d", workout.workoutId];
        
        [self performPUTAsyncRequest:requestPath
                      withDictionary:nil
                  withAuthentication:auth
                 withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *responseCookies) {

                     // Send notification to reload the user current workout view
                     [[NSNotificationCenter defaultCenter] postNotificationName:GEANotificationUserInfoUpdated object:nil userInfo:nil];

                     dispatch_async(dispatch_get_main_queue(), ^{
                         if(completionBlock != nil) {
                             completionBlock(success);
                         }

                     });

        }];

    } else {

        // Send notification to reload the user current workout view
        [[NSNotificationCenter defaultCenter] postNotificationName:GEANotificationUserInfoUpdated object:nil userInfo:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess);
            }
        });
    }
    
}

- (void)requestUserPicturesWithCompletionBlock:(userPicturesCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    if(self.internetIsReachable) {
        
        // Retrieve data from web service API
        NSString *requestPath = @"/api/pictures/get_pictures";
        
        [self performPOSTAsyncRequest:requestPath
                       withDictionary:nil
                   withAuthentication:auth
                  withCompletionBlock:^(GymneaWSClientRequestStatus success, NSDictionary *responseData, NSDictionary *cookies) {

                      NSMutableArray *userPicturesArray = nil;
                      
                      if(success == GymneaWSClientRequestSuccess) {

                          userPicturesArray = [[NSMutableArray alloc] init];
                          
                          for (NSDictionary *userPictureDict in (NSArray *)[responseData objectForKey:@"pictures"]) {

                              UserPicture *userPictureFromDB = [UserPicture getUserPictureInfo:[[userPictureDict objectForKey:@"id"] intValue]];
                              
                              if(userPictureFromDB != nil) {

                                  [userPicturesArray addObject:userPictureFromDB];
                              } else {
                                  
                                  UserPicture *userPictureInfo = [UserPicture updateUserPictureWithId:[[userPictureDict objectForKey:@"id"] intValue]
                                                                                       withDictionary:userPictureDict];
                                  [userPicturesArray addObject:userPictureInfo];
                              }
                          }

                          AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
                          [appDelegate saveContext];
                      }

                      dispatch_async(dispatch_get_main_queue(), ^{
                          if(completionBlock != nil) {
                              completionBlock(success, userPicturesArray);
                          }
                          
                      });
                      
                  }];
        
    } else {
        
        NSArray *userPicturesList = [UserPicture getUserPictures];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(completionBlock != nil) {
                completionBlock(GymneaWSClientRequestSuccess, userPicturesList);
            }

        });

    }

}

- (void)requestImageForUserPicture:(int)pictureId
                          withSize:(GymneaUserPictureImageSize)size
               withCompletionBlock:(userImageCompletionBlock)completionBlock
{
    GEAAuthenticationKeychainStore *keychainStore = [[GEAAuthenticationKeychainStore alloc] init];
    GEAAuthentication *auth = [keychainStore authenticationForIdentifier:@"gymnea"];
    
    UIImage *image = nil;
    BOOL imageInDB = FALSE;
    
    // First try to retrieve the picture from the DB
    UserPicture *userPicture = [UserPicture getUserPictureInfo:pictureId];
    
    if(userPicture) {

            if((size == UserPictureImageSizeMedium) && (userPicture.photoMedium != nil)) {
                image = [UIImage imageWithData:userPicture.photoMedium];
            } else if((size == UserPictureImageSizeBig) && (userPicture.photoBig != nil)) {
                image = [UIImage imageWithData:userPicture.photoBig];
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
        if(size == UserPictureImageSizeMedium) {
            requestPath = [NSString stringWithFormat:@"/body_picture/medium/%d", pictureId];
        } else if(size == UserPictureImageSizeBig) {
            requestPath = [NSString stringWithFormat:@"/body_picture/big/%d", pictureId];
        }

        [self performImageAsyncRequest:requestPath
                        withDictionary:nil
                    withAuthentication:auth
                   withCompletionBlock:^(GymneaWSClientRequestStatus success, UIImage *image) {
                       
                       if(success == GymneaWSClientRequestSuccess) {
                           // Update the exercise picture in the DB by using the UserInfo model

                           if(size == UserPictureImageSizeMedium) {
                               [userPicture updateWithPhotoMedium:UIImagePNGRepresentation(image)];
                           } else if(size == UserPictureImageSizeBig) {
                               [userPicture updateWithPhotoBig:UIImagePNGRepresentation(image)];
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
                completionBlock(GymneaWSClientRequestSuccess, nil);
            }
            
        });
        
    }

}

- (void)performPDFAsyncRequest:(NSString *)path
                withDictionary:(NSDictionary *)values
            withAuthentication:(GEAAuthentication *)auth
           withCompletionBlock:(responsePDFCompletionBlock)completionBlock
{
    
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"application/pdf" forHTTPHeaderField:@"Accept"];
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
                                                           
                                                           if(error == nil && ((responseCode/100)==2) && (responseData != nil)) {
                                                               success = GymneaWSClientRequestSuccess;
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
                                                                   completionBlock(success, responseData);
                                                               }
                                                               
                                                           });
                                                           
                                                       }];
    
    [sessionDataTask resume];
    
}

- (void)performVideoAsyncRequest:(NSString *)path
                  withDictionary:(NSDictionary *)values
              withAuthentication:(GEAAuthentication *)auth
             withCompletionBlock:(responseVideoCompletionBlock)completionBlock
{
    
    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"athlete.gymnea.com" forHTTPHeaderField:@"Host"];
    [request addValue:@"video/mp4" forHTTPHeaderField:@"Accept"];
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

                                                           if(error == nil && ((responseCode/100)==2) && (responseData != nil)) {
                                                               success = GymneaWSClientRequestSuccess;
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
                                                                   completionBlock(success, responseData);
                                                               }

                                                           });

                                                       }];

    [sessionDataTask resume];

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

- (void)performPOSTAsyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth
        withCompletionBlock:(responseCompletionBlock)completionBlock {

    [self performAsyncRequest:path
               withDictionary:values
           withAuthentication:auth
                   withMethod:@"POST"
          withCompletionBlock:completionBlock];
    
}

- (void)performPUTAsyncRequest:(NSString *)path
                withDictionary:(NSDictionary *)values
            withAuthentication:(GEAAuthentication *)auth
           withCompletionBlock:(responseCompletionBlock)completionBlock {

    [self performAsyncRequest:path
               withDictionary:values
           withAuthentication:auth
                   withMethod:@"PUT"
          withCompletionBlock:completionBlock];

}

- (void)performAsyncRequest:(NSString *)path
             withDictionary:(NSDictionary *)values
         withAuthentication:(GEAAuthentication *)auth
                 withMethod:(NSString *)method
        withCompletionBlock:(responseCompletionBlock)completionBlock {

    NSString *requestUrl = [NSString stringWithFormat:@"https://%@%@", kWSDomain, path];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPMethod:method];
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
