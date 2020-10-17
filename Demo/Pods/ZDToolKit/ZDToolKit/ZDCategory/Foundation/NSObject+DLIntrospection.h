//
//  NSObject+DLIntrospection.h
//  DLIntrospection
//
//  Created by Denis Lebedev on 12/27/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//  https://github.com/garnett/DLIntrospection

#import <Foundation/Foundation.h>

@interface NSObject (DLIntrospection)

+ (NSArray<NSString *> *)classes;
+ (NSArray<NSString *> *)subClasses;
+ (NSArray<NSString *> *)properties;
+ (NSArray<NSString *> *)instanceVariables;
+ (NSArray<NSString *> *)classMethods;
+ (NSArray<NSString *> *)instanceMethods;

+ (NSArray<NSString *> *)protocols;
+ (NSDictionary *)descriptionForProtocol:(Protocol *)proto;

+ (NSString *)parentClassHierarchy;

@end
