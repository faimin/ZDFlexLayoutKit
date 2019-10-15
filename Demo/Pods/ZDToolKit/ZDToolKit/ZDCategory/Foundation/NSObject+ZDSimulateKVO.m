//
//  NSObject+ZDSimulateKVO.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/29.
//

#import "NSObject+ZDSimulateKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSObject_ZDSimulateKVO)

static NSString *const ZDKVOPrefix = @"ZDKVOClassPrefix_";
static const void *ZDKVOObserversKey = &ZDKVOObserversKey;
static const void *ZDKVOObserverInfoKeyKey = &ZDKVOObserverInfoKeyKey;
static const void *ZDKVOObserverInfoObserverKey = &ZDKVOObserverInfoObserverKey;

static void ZD_SimulateKVO_Setter(id self, SEL _cmd, id param) {
    // structure super
    struct objc_super superTarget = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    // call super setter method
    void(*superSendMsgFunction)(struct objc_super *, SEL, id) = (__typeof__(superSendMsgFunction))objc_msgSendSuper;
    superSendMsgFunction(&superTarget, _cmd, param);
    
    NSMutableArray *observers = objc_getAssociatedObject(self, ZDKVOObserversKey);
    for (void(^block)(id) in observers) {
        block(param);
    }
}

__unused static Class ZD_SimulateKVO_ClassGetter(id self, SEL _cmd) {
    // self had become to ZDKVOClassPrefix_xxxClass, because of the isa changed.
    return class_getSuperclass(object_getClass(self));
}

@interface NSObject ()
@property (nonatomic, strong) NSMutableArray *zdkvo_observers;
@end

@implementation NSObject (ZDSimulateKVO)

- (void)zd_addObserver:(id)observer forKey:(NSString *)key callbackBlock:(void(^)(id observer, NSString *key, id newValue))block {
    if (key.length == 0) return;
    NSCAssert(![NSStringFromClass(object_getClass(self)) hasPrefix:@"NSKVO"], @"don't use with system's KVO together");
    //@throw [NSException exceptionWithName:@"ZDSimulateKVOException" reason:@"don't use with system's KVO together" userInfo:nil];
    
    SEL setterSelector = ({
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
        SEL selector = NSSelectorFromString(selectorString);
        selector;
    });
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) return;
    
    Class innerKVOSubClass = NULL;
    Class realClass = object_getClass(self);
    NSString *realClassName = NSStringFromClass(realClass);
    if (![realClassName hasPrefix:ZDKVOPrefix]) {
        innerKVOSubClass = [self zd_setupKVOClassWithOriginalClassName:NSStringFromClass(self.class)];
        // set self's isa point to KVOClass
        object_setClass(self, innerKVOSubClass);
    }
    
    if (![self zd_hasSelector:setterSelector]) {
        const char *type = method_getTypeEncoding(setterMethod);
        
        // IMP起实质就是函数指针，所以这里可以直接强转
        IMP kvoSetterIMP = (void *)ZD_SimulateKVO_Setter;
        class_addMethod(innerKVOSubClass, setterSelector, kvoSetterIMP, type);
    }
    
    NSMutableArray *observers = objc_getAssociatedObject(self, ZDKVOObserversKey);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, ZDKVOObserversKey, observers, OBJC_ASSOCIATION_RETAIN);
    }
    
    __auto_type observerInfo = ^void(id newValue){
        if (block) block(observer, key, newValue);
    };
    objc_setAssociatedObject(observerInfo, ZDKVOObserverInfoKeyKey, key, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(observerInfo, ZDKVOObserverInfoObserverKey, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [observers addObject:observerInfo];
}

- (Class)zd_setupKVOClassWithOriginalClassName:(NSString *)originalClassName {
    NSString *kvoClassName = [ZDKVOPrefix stringByAppendingString:originalClassName];
    Class kvoClass = objc_getClass(kvoClassName.UTF8String);
    if (kvoClass) return kvoClass;
    
    // new a class
    Class originalClass = object_getClass(self);
    kvoClass = objc_allocateClassPair(originalClass, kvoClassName.UTF8String, 0);
    
    // add method
    Method kvoClassMethod = class_getInstanceMethod(originalClass, @selector(class));
    const char *type = method_getTypeEncoding(kvoClassMethod);
    //IMP kvoClassIMP = (void *)ZD_SimulateKVO_ClassGetter;
    IMP kvoClassIMP = imp_implementationWithBlock(^(__unsafe_unretained id self){
        return class_getSuperclass(object_getClass(self));
    });
    class_addMethod(kvoClass, @selector(class), kvoClassIMP, type);
    
    // register class
    objc_registerClassPair(kvoClass);
    
    return kvoClass;
}

- (BOOL)zd_hasSelector:(SEL)selector {
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(object_getClass(self), &methodCount);
    BOOL findTargetSEL = NO;
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL tempSelector = method_getName(methodList[i]);
        if (tempSelector == selector) {
            findTargetSEL = YES;
            break;
        }
    }
    free(methodList);
    return findTargetSEL;
}

- (void)zd_removeObserver:(id)observer forKey:(NSString *)key {
    if (!observer || !key) return;
    
    NSMutableArray *observers = objc_getAssociatedObject(self, ZDKVOObserversKey);
    
    id targetObj = nil;
    for (void(^block)(id) in observers) {
        id obsValue = objc_getAssociatedObject(block, ZDKVOObserverInfoObserverKey);
        NSString *obsKey = objc_getAssociatedObject(block, ZDKVOObserverInfoKeyKey);
        if (obsValue == observer && [obsKey isEqualToString:key]) {
            targetObj = block;
            break;
        }
    }
    
    if (targetObj) {
        [observers removeObject:targetObj];
        targetObj = nil;
    }
}

@end
