//
//  EMCI.m
//  EMRuntimeTest
//
//  Created by 郑宇琦 on 2016/10/20.
//  Copyright © 2016年 郑宇琦. All rights reserved.
//

#import "EMCI.h"

@implementation EMCI

+ (void)pAllClass
{
    unsigned int outCount;
    Class * classes = objc_copyClassList(&outCount);
    printf("There are %d classes registed:\n", outCount);
    for (int i = 0; i < outCount; i++) {
        Class class = classes[i];
        const char * nameC = class_getName(class);
        printf("No.%d : %s\n", i, nameC);
    }
    free(classes);
}

+ (void)pSubclass:(NSString *)clsName
{
    Class cls = NSClassFromString(clsName);
    if (cls != nil) {
        int counter = 0;
        unsigned int outCount;
        Class * classes = objc_copyClassList(&outCount);
        for (int i = 0; i < outCount; i++) {
            BOOL isSubclass = false;
            Class class = class_getSuperclass(classes[i]);
            while (class != nil) {
                if (class == cls) {
                    isSubclass = true;
                    break;
                } else {
                    class = class_getSuperclass(class);
                }
            }
            if (isSubclass) {
                printf("No.%d : %s\n", counter++, class_getName(classes[i]));
            }
        }
        free(classes);
    } else {
        printf("Class [%s] is not found.\n", clsName.UTF8String);
    }
}


+ (void)pAllProtocol
{
    unsigned int outCount;
    Protocol * __unsafe_unretained * protocols = objc_copyProtocolList(&outCount);
    printf("There are %d protocols registed:\n", outCount);
    for (int i = 0; i < outCount; i++) {
        Protocol * protocol = protocols[i];
        const char * nameC = protocol_getName(protocol);
        printf("No.%d : %s\n", i, nameC);
    }
    free(protocols);
}

+ (void)sObject:(NSObject *)obj
{
    Class cls = object_getClass(obj);
    NSString * clsName = [[NSString alloc] initWithCString:class_getName(cls) encoding:NSUTF8StringEncoding];
    sClsName = clsName;
    sCls = cls;
    printf("%s > \n", clsName.UTF8String);
}

+ (void)sClass:(NSString *)clsName
{
    Class cls = NSClassFromString(clsName);
    if (cls != nil) {
        sClsName = clsName;
        sCls = cls;
        printf("%s > \n", clsName.UTF8String);
    } else {
        printf("Class [%s] is not found.\n", clsName.UTF8String);
    }
}

+ (void)sBack
{
    sClsName = nil;
    sCls = nil;
    printf("Back.\n");
}

+ (void)pInherit
{
    if ([self checkCls]) {
        NSString * output = [[NSString alloc] init];
        output = [output stringByAppendingFormat: @"%@", sClsName];
        Class cls = [sCls superclass];
        while (cls != nil) {
            const char * nameC = class_getName(cls);
            NSString * name = [[NSString alloc] initWithCString:nameC encoding: NSUTF8StringEncoding];
            output = [output stringByAppendingFormat: @" -> %@", name];
            cls = [cls superclass];
        }
        printf("%s\n", output.UTF8String);
    }
}

+ (void) pProtocol
{
    if ([self checkCls]) {
        unsigned int outCount;
        Protocol * __unsafe_unretained * protocols = class_copyProtocolList(sCls, &outCount);
        printf("Class [%s] conforms %d protocols:\n", sClsName.UTF8String, outCount);
        for (int i = 0; i < outCount; i++) {
            Protocol * protocol = protocols[i];
            const char * nameC = protocol_getName(protocol);
            printf("No.%d: %s\n", i, nameC);
        }
        free(protocols);
    }
}

+ (void)pProtocolDetail:(int)index
{
    unsigned int outCount;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList(sCls, &outCount);
    Protocol * protocol = protocols[index];
    unsigned int count[4];
    struct objc_method_description * method[4];
    method[0] = protocol_copyMethodDescriptionList(protocol, true, true, &count[0]);
    method[1] = protocol_copyMethodDescriptionList(protocol, true, false, &count[1]);
    method[2] = protocol_copyMethodDescriptionList(protocol, false, true, &count[2]);
    method[3] = protocol_copyMethodDescriptionList(protocol, false, false, &count[3]);
    printf("Protocol [%s] has %d methods:\n", protocol_getName(protocol), count[0] + count[1] + count[2] + count[3]);
    int counter = 0;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < count[i]; j++) {
            struct objc_method_description m = method[i][j];
            SEL sel = m.name;
            const char * nameC = sel_getName(sel);
            printf("No.%d: %s\n--------Arguments: %s\n\n", counter++, nameC, m.types);
        }
    }
    free(protocols);
}

+ (void)pInstanceMethod
{
    if ([self checkCls]) {
        unsigned int outCount;
        Method * methods = class_copyMethodList(sCls, &outCount);
        printf("Class [%s] has %d instance methods:\n", sClsName.UTF8String, outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            const char * nameC = sel_getName(sel);
            printf("No.%d: (-)%s\n", i, nameC);
        }
        free(methods);
    }
}

+ (void)pClassMethod
{
    if ([self checkCls]) {
        unsigned int outCount;
        Method * methods = class_copyMethodList(object_getClass(sCls), &outCount);
        printf("Class [%s] has %d class methods:\n", sClsName.UTF8String, outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            const char * nameC = sel_getName(sel);
            printf("No.%d: (+)%s\n", i, nameC);
        }
        free(methods);
    }
}

+ (void)pInstanceMethodDetail:(int)index
{
    if ([self checkCls]) {
        [self methodDetailWithClass:sCls atIndex:index];
    }
}

+ (void)pClassMethodDetail:(int)index
{
    if ([self checkCls]) {
        [self methodDetailWithClass:object_getClass(sCls) atIndex:index];
    }
}

+ (void)pInstanceVariable
{
    if ([self checkCls]) {
        unsigned int outCount;
        Ivar * vars = class_copyIvarList(sCls, &outCount);
        printf("Class [%s] has %d instance variables:\n", sClsName.UTF8String, outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar var = vars[i];
            const char * nameC = ivar_getName(var);
            const char * typeC = ivar_getTypeEncoding(var);
            NSString * type = [[NSString alloc] initWithCString:typeC encoding:NSUTF8StringEncoding];
            printf("No.%d: (-)%s: %s\n", i, nameC, [self gNameWithEncodedType:type].UTF8String);
        }
        free(vars);
    }
}

//MARK: - Private

static NSString * sClsName;
static Class sCls;

+ (BOOL)checkCls
{
    if (sCls != nil) {
        return true;
    } else {
        printf("Class is not set.\n");
        return false;
    }
}

+ (NSString *)gNameWithEncodedType:(NSString *)type
{
    NSDictionary * decoder = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"char", @"c",
                              @"int", @"i",
                              @"short", @"s",
                              @"long", @"l",
                              @"long long", @"q",
                              @"unsigned char", @"C",
                              @"unsigned int", @"I",
                              @"unsigned short", @"S",
                              @"unsigned long", @"l",
                              @"unsigned long long", @"Q",
                              @"float", @"f",
                              @"double", @"d",
                              @"C++ bool or a C99 _Bool", @"B",
                              @"void", @"v",
                              @"character string (char *)", @"*",
                              @"id", @"@",
                              @"Class", @"#",
                              @"SEL", @":",
                              @"pointer", @"^",
                              @"unknown", @"?",
                              nil
                              ];
    NSString * result = [[NSString alloc] init];
    result = [result stringByAppendingFormat:@"%s -> ", type.UTF8String];
    NSUInteger len = type.length;
    if (len > 5) {
        result = [result stringByAppendingString:type];
    } else {
        for (int i = 0; i < len; i++) {
            NSString * s = [type substringWithRange:NSMakeRange(i, 1)];
            NSString * ds = [decoder objectForKey:s];
            if (ds != nil) {
                result = [result stringByAppendingFormat:@"(%s)", ds.UTF8String];
            } else {
                result = [result stringByAppendingFormat:@"%s", s.UTF8String];
            }
        }
    }
    return result;
}

+ (void)methodDetailWithClass:(Class)cls atIndex:(int)index
{
    const char * clsNameC = class_getName(cls);
    unsigned int outCount;
    Method * methods = class_copyMethodList(cls, &outCount);
    if (index < outCount) {
        Method method = methods[index];
        SEL sel = method_getName(method);
        const char * nameC = sel_getName(sel);
        printf("[%s %s] > \n", clsNameC, nameC);
        unsigned int count = method_getNumberOfArguments(method);
        printf("Method has %d arguments:\n", count);
        for (int i = 0; i < count; i++) {
            char * typeC = method_copyArgumentType(method, i);
            NSString * type = [[NSString alloc] initWithCString:typeC encoding:NSUTF8StringEncoding];
            printf("No.%d : %s\n", i, [self gNameWithEncodedType:type].UTF8String);
            free(typeC);
        }
        char * typeC = method_copyReturnType(method);
        NSString * type = [[NSString alloc] initWithCString:typeC encoding:NSUTF8StringEncoding];
        printf("Return %s\n", [self gNameWithEncodedType:type].UTF8String);
        free(typeC);
    } else {
        printf("Index out of range.\n");
    }
    free(methods);
}

//MARK: - ShortInterface
+ (void)PAC
{
    [self pAllClass];
}

+ (void)PAP
{
    [self pAllProtocol];
}

+ (void)SO:(NSObject *)obj
{
    [self sObject:obj];
}

+ (void)SC:(NSString *)clsName
{
    [self sClass:clsName];
}

+ (void)SB
{
    [self sBack];
}

+ (void)PP
{
    [self pProtocol];
}

+ (void)PPD:(int)index
{
    [self pProtocolDetail:index];
}

+ (void)PI
{
    [self pInherit];
}

+ (void)PS:(NSString *)clsName;
{
    [self pSubclass:clsName];
}

+ (void)PIM
{
    [self pInstanceMethod];
}

+ (void)PCM
{
    [self pClassMethod];
}

+ (void)PIMD:(int)index
{
    [self pInstanceMethodDetail:index];
}

+ (void)PCMD:(int)index
{
    [self pClassMethodDetail:index];
}

+ (void)PIV
{
    [self pInstanceVariable];
}

@end
