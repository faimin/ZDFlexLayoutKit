//
//  NSDictionary+ZDUtility.m
//  Pods
//
//  Created by Zero on 2017/5/20.
//
//

#import "NSDictionary+ZDUtility.h"
#import <Security/Security.h>

@implementation NSDictionary (ZDUtility)

// reference: http://stackoverflow.com/questions/9948698/store-nsdictionary-in-keychain
- (void)zd_storeToKeychainWithKey:(NSString *)aKey {
    // serialize dict
    NSData *serializedDictionary = [NSKeyedArchiver archivedDataWithRootObject:self];
    //[NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    // encrypt in keychain

    // first, delete potential existing entries with this key (it won't auto update)
    [self zd_deleteFromKeychainWithKey:aKey];
    
    // setup keychain storage properties
    NSDictionary *storageQuery = @{
                                   (__bridge id)kSecAttrAccount:    aKey,
                                   (__bridge id)kSecValueData:      serializedDictionary,
                                   (__bridge id)kSecClass:          (__bridge id)kSecClassGenericPassword,
                                   (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked
                                   };
    OSStatus osStatus = SecItemAdd((__bridge CFDictionaryRef)storageQuery, nil);
    if (osStatus != noErr) {
        // do someting with error
    }
}

+ (NSDictionary *)zd_dictionaryFromKeychainWithKey:(NSString *)aKey {
    // setup keychain query properties
    NSDictionary *readQuery = @{
                                (__bridge id)kSecAttrAccount: aKey,
                                (__bridge id)kSecReturnData: (id)kCFBooleanTrue,
                                (__bridge id)kSecClass:      (__bridge id)kSecClassGenericPassword
                                };
    
    CFDataRef serializedDictionary = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)readQuery, (CFTypeRef *)&serializedDictionary);
    if (osStatus == noErr) {
        // deserialize dictionary
        NSData *data = (__bridge NSData *)serializedDictionary;
        NSDictionary *storedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //[NSPropertyListSerialization propertyListFromData:(__bridge NSData *)(serializedDictionary) mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&error];
        return storedDictionary;
    }
    else {
        // do something with error
        return nil;
    }
}

- (void)zd_deleteFromKeychainWithKey:(NSString *)aKey {
    // setup keychain query properties
    NSDictionary *deletableItemsQuery = @{
                                          (__bridge id)kSecAttrAccount :      aKey,
                                          (__bridge id)kSecClass :            (__bridge id)kSecClassGenericPassword,
                                          (__bridge id)kSecMatchLimit :       (__bridge id)kSecMatchLimitAll,
                                          (__bridge id)kSecReturnAttributes : (id)kCFBooleanTrue
                                          };
    
    CFArrayRef itemList = NULL;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)deletableItemsQuery, (CFTypeRef *)&itemList);
    // each item in the array is a dictionary
    NSArray *itemListArray = (__bridge NSArray *)itemList;
    for (NSDictionary *item in itemListArray) {
        NSMutableDictionary *deleteQuery = [item mutableCopy];
        [deleteQuery setValue:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        // do delete
        osStatus = SecItemDelete((CFDictionaryRef)deleteQuery);
        if(osStatus != noErr) {
            // do something with error
        }
    }
}

- (NSMutableDictionary *)zd_mutableDictionary {
    if (![self isKindOfClass:[NSDictionary class]]) return nil;
    
    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        return (NSMutableDictionary *)self;
    }
    else {
        return [NSMutableDictionary dictionaryWithDictionary:self];
    }
}

@end
