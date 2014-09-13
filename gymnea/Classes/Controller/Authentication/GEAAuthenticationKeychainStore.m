//
//  GEAAuthenticationKeychainStore.m
//  Gymnea
//
//  Created by Albert Nadal Garriga on 2014-08-01.
//  Copyright (c) 2013 Gymnea. All rights reserved.
//

#import "GEAAuthenticationKeychainStore.h"

@interface GEAAuthenticationKeychainStore ()

@property (nonatomic, strong) NSMutableDictionary *authentications;

@end

@implementation GEAAuthenticationKeychainStore

- (void)setAuthentication:(GEAAuthentication *)authentication forIdentifier:(NSString *)identifier {

  NSData *archivedAuthentication = [NSKeyedArchiver archivedDataWithRootObject:authentication];
  [self _setKeychainData:archivedAuthentication forKey:identifier];

}

- (GEAAuthentication *)authenticationForIdentifier:(NSString *)identifier {

  NSData *data = [self _keychainDataForKey:identifier];
  
  if (!data) {
    return nil;
  }
  
  GEAAuthentication *authentication = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  return authentication;
  
}

#pragma mark - Internal Methods

- (NSString *)keychainServiceIdentifier {
  
  return [[NSBundle mainBundle] bundleIdentifier];
  
}

+ (NSString *)serviceName {
  
  return  @"com.gymnea";
  
}

- (NSString *)serviceName {
  
  return [[self class] serviceName];
  
}

+ (NSMutableDictionary *)keychainSearchDictionaryForKey:(NSString *)key {

  NSMutableDictionary *dict = [NSMutableDictionary dictionary];

  [dict setValue:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
  [dict setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
  [dict setValue:[self serviceName] forKey:(__bridge id)kSecAttrService];
  [dict setValue:key forKey:(__bridge id)kSecAttrAccount];

  return dict;
}

- (NSMutableDictionary *)keychainSearchDictionaryForKey:(NSString *)key {

  return [[self class] keychainSearchDictionaryForKey:key];

}

- (void)_setKeychainData:(id)data forKey:(NSString *)key {

  NSMutableDictionary *searchDict = [self keychainSearchDictionaryForKey:key];

  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDict, NULL);

  if (status == errSecItemNotFound) {
    
    if ([data isKindOfClass:[NSData class]]) {
      [searchDict setValue:data forKey:(__bridge id)kSecValueData];
    } else {
    [searchDict setValue:data forKey:(__bridge id)kSecValueRef];
    }
    
    status = SecItemAdd((__bridge CFDictionaryRef)searchDict, NULL);
    if (status != errSecSuccess) {
#if DEBUG
      NSLog(@"Failed to add %@ to keychain: %ld", key, status);
#endif
    }
    
  } else if (status == errSecSuccess) {
    
    CFDictionaryRef updateDataDictRef = (__bridge_retained CFDictionaryRef)@{(__bridge id)kSecValueData : data};
    status = SecItemUpdate((__bridge CFDictionaryRef)searchDict, updateDataDictRef);
    CFRelease(updateDataDictRef);
    
    if (status != errSecSuccess) {
#if DEBUG
      NSLog(@"Error when updating item %@ in keychain: %ld", key, status);
#endif
    }
    
  }
  
}

- (id)_keychainDataForDictionary:(NSDictionary *)searchDict {
  
  CFDataRef result = nil;
  CFDictionaryRef cfQuery = (__bridge_retained CFDictionaryRef)searchDict;
  OSStatus status = SecItemCopyMatching(cfQuery, (CFTypeRef *)&result);
  CFRelease(cfQuery);
  if (status == errSecSuccess) {
    return (__bridge_transfer NSData *)result;
  }
  
  return nil;

}

- (id)_keychainObjectForKey:(NSString *)key {
  
  NSMutableDictionary *searchDict = [self keychainSearchDictionaryForKey:key];
  CFDataRef result = nil;
  CFDictionaryRef cfQuery = (__bridge_retained CFDictionaryRef)searchDict;
  OSStatus status = SecItemCopyMatching(cfQuery, (CFTypeRef *)&result);
  CFRelease(cfQuery);
  if (status == errSecSuccess) {
    return (__bridge_transfer id)result;
  }
  
  return nil;
  
}

- (NSData *)_keychainDataForKey:(NSString *)key {
  
  NSMutableDictionary *searchDict = [self keychainSearchDictionaryForKey:key];
  [searchDict setValue:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
  return [self _keychainDataForDictionary:searchDict];
  
}

- (id)objectForKey:(NSString *)key {
  
  return [self _keychainObjectForKey:key];
  
}

- (void)setData:(NSData *)data forKey:(NSString *)key {
  
  [self _setKeychainData:data forKey:key];
  
}

- (NSData *)dataForKey:(NSString *)key {
  
  return [self _keychainDataForKey:key];

}

+ (void)clearAllData {
  
  NSMutableDictionary *findAllKeysDict = [NSMutableDictionary dictionaryWithDictionary:@{(__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
                                                                                         (__bridge id)kSecReturnPersistentRef: (__bridge id)kCFBooleanTrue,
                                                                                         (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
                                                                                         (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword}];
  
  CFDataRef result = nil;
  CFDictionaryRef findAllKeysDictRef = (__bridge_retained CFDictionaryRef)findAllKeysDict;
  SecItemCopyMatching(findAllKeysDictRef, (CFTypeRef *)&result);
  CFRelease(findAllKeysDictRef);
  
  if (result != NULL) {
    NSArray *items = (__bridge NSArray *)result;
    for (NSDictionary *item in items) {
      
      NSString *itemAccount;
      // WOFO-1090: Dual-datatype-workaround for when previous account value have been stored as data instead of string:
      id account = [item valueForKey:(__bridge id)kSecAttrAccount];
      if ([account isKindOfClass:[NSData class]]) {
        itemAccount = [NSString.alloc initWithData:account encoding:NSUTF8StringEncoding];
      } else {
        itemAccount = account;
      }
      CFDictionaryRef itemDict = (__bridge_retained CFDictionaryRef)[self keychainSearchDictionaryForKey:itemAccount];
      OSStatus status = SecItemDelete(itemDict);
      CFRelease(itemDict);
      if (status != errSecSuccess) {
#if DEBUG
        NSLog(@"%s Failed to delete keychain item '%@', error: %ld.", __PRETTY_FUNCTION__, itemAccount, status);
#endif
      }
    }
  }
  
#if DEBUG
  NSLog(@"%s Deleted all existing data items in keychain.", __PRETTY_FUNCTION__);
#endif
  
}


@end
