//
//  NSObject+Runtime.m
//  ZDUtility
//
//  Created by Zero on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDRuntime.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSObject_ZDRuntime)

@implementation NSObject (ZDRuntime)

#pragma mark - Dealloc Blocks

- (void)zd_deallocBlock:(ZD_DisposeBlock)deallocBlock {
    if (!deallocBlock) return;
    
    @autoreleasepool {
        NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, _cmd);
        // add array of dealloc blocks if not existing yet
        if (!deallocBlocks) {
            deallocBlocks = [[NSMutableArray alloc] init];
            objc_setAssociatedObject(self, _cmd, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
        }
        
        ZDObjectBlockExecutor *blockExecutor = [[ZDObjectBlockExecutor alloc] initWithBlock:deallocBlock realTarget:self];
        ///原理: 当self释放时,会先释放它本身的关联对象,所以在这个属性对象的dealloc里执行回调,操作remove观察者等操作
        [deallocBlocks addObject:blockExecutor];
    }
}

+ (BOOL)zd_addInstanceMethodWithSelector:(SEL)selector block:(void(^)(id))block {
    // don't accept NULL SEL
    NSParameterAssert(selector);
    
    // don't accept NULL block
    NSParameterAssert(block);
    
    // See http://stackoverflow.com/questions/6357663/casting-a-block-to-a-void-for-dynamic-class-method-resolution
    
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7
    void *impBlockForIMP = (void *)objc_unretainedPointer(block);
#else
    id impBlockForIMP = (__bridge id)(__bridge void *)(block);
#endif
    
    IMP myIMP = imp_implementationWithBlock(impBlockForIMP);
    
    return class_addMethod(self, selector, myIMP, "v@:");
}

#pragma mark - Method Swizzling

+ (void)zd_swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector {
    // my own class is being targetted
    Class myClass = [self class];
    
    // get the methods from the selectors
    Method originalMethod = class_getInstanceMethod(myClass, selector);
    Method otherMethod = class_getInstanceMethod(myClass, otherSelector);
    
    // 把swizzle的实现方法添加给originMethod，如果没有实现origin方法，则添加成功，否则添加失败。
    // 如果直接exchange的话，那么会覆盖掉父类的方法。
    if (class_addMethod(myClass, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod))) {
        class_replaceMethod(myClass, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, otherMethod);
    }
}

+ (void)zd_swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector {
    /// http://nshipster.com/method-swizzling/
    /// 文中指出swizzle一个类方法用 Class class = object_getClass((id)self);
    /// 原因: class方法默认是调用的object_getClass(self),但是KVO方法中重写了原来对象的class方法,如果还调class方法,还是会返回class类,而不是KVO新创建的那个子类(这个类才是此时真实的类),所以为了防止这种情况出现,直接调用底层的object_getClass()方法来返回真正的类.
    Class myClass = object_getClass(self);
    Method originalMethod = class_getClassMethod(myClass, selector);
    Method otherMethod = class_getClassMethod(myClass, otherSelector);
    
    method_exchangeImplementations(originalMethod, otherMethod);
}

#pragma mark - Copy Property

- (instancetype)zd_mutableCopy {
    Class aClass = [self class];
    id newSelf = [aClass new];
    
    // 容器类
    if ([self conformsToProtocol:@protocol(NSFastEnumeration)]) {
        if ([self respondsToSelector:@selector(enumerateKeysAndObjectsUsingBlock:)]) {
            NSMutableDictionary *newTable = [newSelf respondsToSelector:@selector(mutableCopy)] ? [newSelf mutableCopy] : newSelf;
            BOOL responseSetObjForKey = [newTable respondsToSelector:@selector(setObject:forKey:)];
            [(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id newObj = [obj zd_mutableCopy];
                if (responseSetObjForKey && newObj) {
                    [newTable setObject:newObj forKey:key];
                }
            }];
            newSelf = newTable;
        }
        else if ([self respondsToSelector:@selector(enumerateObjectsUsingBlock:)]) {
            NSMutableArray *newMap = [newSelf respondsToSelector:@selector(mutableCopy)] ? [newSelf mutableCopy] : newSelf;
            BOOL responseAddObj = [newMap respondsToSelector:@selector(addObject:)];
            [(NSArray *)self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id newObj = [obj zd_mutableCopy];
                if (responseAddObj && newObj) {
                    [newMap addObject:newObj];
                }
            }];
            newSelf = newMap;
        }
        else {
            NSCAssert1(NO, @"sorry, not surrport the class type: %s", object_getClassName(self));
        }
    }
    // 普通类
    else {
        NSMutableArray<NSString *> *keys = @[].mutableCopy;
        while (aClass && aClass != [NSObject class]) {
            @autoreleasepool {
                unsigned int count = 0;
                objc_property_t *properties = class_copyPropertyList(aClass, &count);
                for (int i = 0; i < count; ++i) {
                    @autoreleasepool {
                        objc_property_t property = properties[i];
                        if (property) {
                            const char *readOnly = property_copyAttributeValue(property, "R");
                            if (readOnly) continue;
                            const char *propertyName = property_getName(property);
                            if (propertyName == NULL) continue;
                            NSString *keyName = [NSString stringWithUTF8String:propertyName];
                            if (keyName) {
                                [keys addObject:keyName];
                            }
                        }
                    }
                }
                free(properties);
                aClass = class_getSuperclass(aClass);
            }
        }
        
        [newSelf setValuesForKeysWithDictionary:[self dictionaryWithValuesForKeys:keys]];
    }
    
    return newSelf;
}

#pragma mark - Associate

- (void)zd_setStrongAssociateValue:(id)value forKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)zd_getStrongAssociatedValueForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)zd_setCopyAssociateValue:(id)value forKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (id)zd_getCopyAssociatedValueForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

- (void)zd_setUnsafeUnretainedAssociateValue:(id)value forKey:(const void *)key {
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)zd_getUnsafeUnretainedAssociatedValueForKey:(const void *)key {
    return objc_getAssociatedObject(self, key);
}

// 此处是利用block捕获外部变量的原理实现的.
// 其实把value作为一个对象的weak属性,然后绑定这个对象也可以实现,当get时拿到这个对象,并获取它那个weak属性即可.
- (void)zd_setWeakAssociateValue:(id)value forKey:(const void *)key {
    if (!key) return;
    
#if 1
    __weak id weakValue = value;
    objc_setAssociatedObject(self, key, ^id{
        return weakValue;
    }, OBJC_ASSOCIATION_COPY);
#else
    NSHashTable *table = [NSHashTable weakObjectsHashTable];
    [table addObject:value];
    objc_setAssociatedObject(self, key, table, OBJC_ASSOCIATION_RETAIN);
#endif
}

- (id)zd_getWeakAssociateValueForKey:(const void *)key {
    if (!key) return nil;
    
#if 1
    id(^tempBlock)(void) = objc_getAssociatedObject(self, key);
    if (tempBlock) {
        return tempBlock();
    }
    return nil;
#else
    NSHashTable *table = objc_getAssociatedObject(self, key);
    id value = [table allObjects].firstObject;
    return value;
#endif
}

- (void)zd_removeAssociatedValues {
	objc_removeAssociatedObjects(self);
}

#pragma mark - Print Property
//https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
static NSString *ZD_DecodeType(const char *cString) {
    if (strcmp(cString, @encode(id)) == 0) return @"id";
    if (strcmp(cString, @encode(void)) == 0) return @"void";
    if (strcmp(cString, @encode(void *)) == 0) return @"void *";
    if (strcmp(cString, @encode(float)) == 0) return @"float";
    if (strcmp(cString, @encode(int)) == 0) return @"int";
    if (strcmp(cString, @encode(unsigned int)) == 0) return @"unsigned int";
    if (strcmp(cString, @encode(BOOL)) == 0) return @"BOOL";
    if (strcmp(cString, @encode(char *)) == 0) return @"char *";
    if (strcmp(cString, @encode(double)) == 0) return @"double";
    if (strcmp(cString, @encode(long double)) == 0) return @"long double";
    if (strcmp(cString, @encode(long long)) == 0) return @"long long";
    if (strcmp(cString, @encode(unsigned long long)) == 0) return @"unsigned long long";
    if (strcmp(cString, @encode(Class)) == 0) return @"class";
    if (strcmp(cString, @encode(SEL)) == 0) return @"SEL";
    
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    }
    else if ([[result substringToIndex:1] isEqualToString:@"^"]) {
        result = [NSString stringWithFormat:@"%@ *", ZD_DecodeType([[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding])];
    }
    return result;
}

+ (NSArray<NSString *> *)zd_classes {
    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (unsigned int i = 0 ; i < classesCount; i++) {
        [result addObject:NSStringFromClass(classes[i])];
    }
    free(classes);
    
    return [result sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray<NSString *> *)zd_subClasses {
    Class myClass = [self class];
    NSMutableArray *mySubclasses = @[].mutableCopy;
    unsigned int classesCount;
    Class *classes = objc_copyClassList(&classesCount);
    for (unsigned int i = 0; i < classesCount; i++) {
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while (superClass && superClass != myClass);
        
        if (superClass) {
            [mySubclasses addObject:NSStringFromClass(classes[i])];
        }
    }
    free(classes);
    
    return mySubclasses;
}

+ (NSArray *)zd_classMethods {
    return [self zd_methodsForClass:object_getClass([self class]) typeFormat:@"+"];
}

+ (NSArray *)zd_instanceMethods {
    return [self zd_methodsForClass:[self class] typeFormat:@"-"];
}

+ (NSArray<NSString *> *)zd_properties {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (unsigned int i = 0; i < outCount; i++) {
        [result addObject:[self zd_formattedPropery:properties[i]]];
    }
    free(properties);
    
    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)zd_instanceVariables {
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (unsigned int i = 0; i < outCount; i++) {
        NSString *type = ZD_DecodeType(ivar_getTypeEncoding(ivars[i]));
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    
    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)zd_protocols {
    unsigned int outCount;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList([self class], &outCount);
    
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (unsigned int i = 0; i < outCount; i++) {
        unsigned int adoptedCount;
        Protocol * __unsafe_unretained *adotedProtocols = protocol_copyProtocolList(protocols[i], &adoptedCount);
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding];
        
        NSMutableArray<NSString *> *adoptedProtocolNames = @[].mutableCopy;
        for (unsigned int idx = 0; idx < adoptedCount; idx++) {
            [adoptedProtocolNames addObject:[NSString stringWithCString:protocol_getName(adotedProtocols[idx]) encoding:NSUTF8StringEncoding]];
        }
        free(adotedProtocols);
        
        NSString *protocolDescription = protocolName;
        if (adoptedProtocolNames.count) {
            protocolDescription = [NSString stringWithFormat:@"%@ <%@>", protocolName, [adoptedProtocolNames componentsJoinedByString:@", "]];
        }
        
        [result addObject:protocolDescription];
    }
    free(protocols);
    
    return result.count ? [result copy] : nil;
}

+ (NSDictionary<NSString *, NSArray<NSString *> *> *)zd_descriptionForProtocol:(Protocol *)proto {
    NSArray<NSString *> *requiredMethods = [[self zd_formattedMethodsForProtocol:proto required:YES instance:NO] arrayByAddingObjectsFromArray:[self zd_formattedMethodsForProtocol:proto required:YES instance:YES]];
    
    NSArray<NSString *> *optionalMethods = [[self zd_formattedMethodsForProtocol:proto required:NO instance:NO] arrayByAddingObjectsFromArray:[self zd_formattedMethodsForProtocol:proto required:NO instance:YES]];
    
    unsigned int propertiesCount;
    NSMutableArray<NSString *> *propertyDescriptions = @[].mutableCopy;
    objc_property_t *properties = protocol_copyPropertyList(proto, &propertiesCount);
    for (unsigned int i = 0; i < propertiesCount; i++) {
        [propertyDescriptions addObject:[self zd_formattedPropery:properties[i]]];
    }
    free(properties);
    
    NSMutableDictionary *methodsAndProperties = @{}.mutableCopy;
    if (requiredMethods.count) {
        [methodsAndProperties setObject:requiredMethods forKey:@"@required"];
    }
    if (optionalMethods.count) {
        [methodsAndProperties setObject:optionalMethods forKey:@"@optional"];
    }
    if (propertyDescriptions.count) {
        [methodsAndProperties setObject:propertyDescriptions.copy forKey:@"@properties"];
    }
    
    return methodsAndProperties.count ? methodsAndProperties.copy : nil;
}

+ (NSString *)zd_parentClassHierarchy {
    NSMutableString *result = [NSMutableString string];
    
    Class superClass = [self class];
    while (superClass) {
        [result appendFormat:@" -> %@", NSStringFromClass(superClass)];
        superClass = class_getSuperclass(superClass);
    }
    
    return result.copy;
}

#pragma mark - Private

+ (NSArray<NSString *> *)zd_methodsForClass:(Class)class typeFormat:(NSString *)type {
    unsigned int outCount;
    Method *methods = class_copyMethodList(class, &outCount);
    NSMutableArray<NSString *> *result = @[].mutableCopy;
    for (unsigned int i = 0; i < outCount; i++) {
        NSString *methodDescription = [NSString stringWithFormat:@"%@ (%@)%@",
                                       type,
                                       ZD_DecodeType(method_copyReturnType(methods[i])),
                                       NSStringFromSelector(method_getName(methods[i]))];
        
        NSInteger args = method_getNumberOfArguments(methods[i]);
        NSMutableArray<NSString *> *selParts = [[methodDescription componentsSeparatedByString:@":"] mutableCopy];
        
        int offset = 2; //1-st arg is object (@), 2-nd is SEL (:)
        for (int idx = offset; idx < args; idx++) {
            NSString *returnType = ZD_DecodeType(method_copyArgumentType(methods[i], idx));
            selParts[idx - offset] = [NSString stringWithFormat:@"%@:(%@)arg%d",
                                      selParts[idx - offset],
                                      returnType,
                                      idx - offset];
        }
        [result addObject:[selParts componentsJoinedByString:@" "]];
    }
    free(methods);
    
    return result.count ? [result copy] : nil;
}

+ (NSArray<NSString *> *)zd_formattedMethodsForProtocol:(Protocol *)proto required:(BOOL)required instance:(BOOL)instance {
    unsigned int methodCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(proto, required, instance, &methodCount);
    NSMutableArray *methodsDescription = @[].mutableCopy;
    for (unsigned int i = 0; i < methodCount; i++) {
        [methodsDescription addObject:
         [NSString stringWithFormat:@"%@ (%@)%@",
          instance ? @"-" : @"+",
          @"void",
          NSStringFromSelector(methods[i].name)]];
    }
    free(methods);
    
    return [methodsDescription copy];
}

+ (NSString *)zd_formattedPropery:(objc_property_t)prop {
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(prop, &attrCount);
    NSMutableDictionary<NSString *, NSString *> *attributes = @{}.mutableCopy;
    for (unsigned int idx = 0; idx < attrCount; idx++) {
        NSString *name = [NSString stringWithCString:attrs[idx].name encoding:NSUTF8StringEncoding];
        NSString *value = [NSString stringWithCString:attrs[idx].value encoding:NSUTF8StringEncoding];
        name ? (attributes[name] = value) : nil;
    }
    free(attrs);
    
    // Property Attribute Description : https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
    NSMutableArray<NSString *> *attrsArray = @[].mutableCopy;
    [attrsArray addObject:attributes[@"N"] ? @"nonatomic" : @"atomic"];
    
    if (attributes[@"&"]) {
        [attrsArray addObject:@"strong"];
    } else if (attributes[@"C"]) {
        [attrsArray addObject:@"copy"];
    } else if (attributes[@"W"]) {
        [attrsArray addObject:@"weak"];
    } else {
        [attrsArray addObject:@"assign"];
    }
    
    if (attributes[@"R"]) {
        [attrsArray addObject:@"readonly"];
    }
    if (attributes[@"G"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"getter=%@", attributes[@"G"]]];
    }
    if (attributes[@"S"]) {
        [attrsArray addObject:[NSString stringWithFormat:@"setter=%@", attributes[@"G"]]];
    }
    
    NSMutableString *property = [NSMutableString stringWithFormat:@"@property "];
    [property appendFormat:@"(%@) %@ %@", [attrsArray componentsJoinedByString:@", "], ZD_DecodeType([[attributes objectForKey:@"T"] cStringUsingEncoding:NSUTF8StringEncoding]), [NSString stringWithCString:property_getName(prop) encoding:NSUTF8StringEncoding]];
    return [property copy];
}

@end


//========================================================
#pragma mark - ZDObjectBlockExecutor
//========================================================

@implementation ZDObjectBlockExecutor

- (void)dealloc {
    @autoreleasepool {
        if (nil != self.deallocBlock) {
            self.deallocBlock(self);
            _deallocBlock = nil;
            NSLog(@"%s, 成功移除对象", __PRETTY_FUNCTION__);
        }
    }
}

- (instancetype)initWithBlock:(ZD_DisposeBlock)deallocBlock realTarget:(id)realTarget {
    if (self = [super init]) {
        //属性设为readonly,并用指针指向方式,是参照RACDynamicSignal中的写法
        self->_deallocBlock = [deallocBlock copy];
        self->_realTarget = realTarget;
    }
    return self;
}

@end
