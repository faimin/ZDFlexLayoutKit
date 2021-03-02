//
//  EMCI.h
//  EMRuntimeTest
//
//  Created by 郑宇琦 on 2016/10/20.
//  Copyright © 2016年 郑宇琦. All rights reserved.
//  https://github.com/enums/EMClassIntrospection

#import <Foundation/Foundation.h>

@interface ZDRuntimeTool : NSObject

/**
 Print all class.
 */
+ (void)pAllClass;

/**
 Print all subclass of the superclass.

 @param clsName the superclass
 */
+ (void)pSubclass:(NSString *)clsName;

/**
 Print all protocol/
 */
+ (void)pAllProtocol;

/**
 Set target class with an object.

 @param obj is the object
 */
+ (void)sObject:(NSObject *)obj;

/**
 Set target class with a NSString

 @param clsName is the class name
 */
+ (void)sClass:(NSString *)clsName;

/**
 Cancle the target
 */
+ (void)sBack;

/**
 Print the inhenrit relationship of target class
 */
+ (void)pInherit;

/**
 Print the protocols of target class conforms
 */
+ (void)pProtocol;

/**
 Print the detail of the protocol selected by index

 @param index is the index
 */
+ (void)pProtocolDetail:(int)index;

/**
 Print instance methods of target class
 */
+ (void)pInstanceMethod;

/**
 Print class methods of target class
 */
+ (void)pClassMethod;

/**
 Print the detail of the instance method selected by index

 @param index is the index
 */
+ (void)pInstanceMethodDetail:(int)index;

/**
 Print the detail of the class method selected by index

 @param index is the index
 */
+ (void)pClassMethodDetail:(int)index;

/**
 Print the instance variable of target class
 */
+ (void)pInstanceVariable;

//MARK: - ShortInterface
+ (void)PAC;
+ (void)PS:(NSString *)clsName;
+ (void)PAP;

+ (void)SO:(NSObject *)obj;
+ (void)SC:(NSString *)clsName;
+ (void)SB;

+ (void)PI;

+ (void)PP;
+ (void)PPD:(int)index;

+ (void)PIM;
+ (void)PCM;

+ (void)PIMD:(int)index;
+ (void)PCMD:(int)index;

+ (void)PIV;

@end
