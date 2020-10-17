//
//  ZDSafe.m
//  ZDUtility
//
//  Created by Zero on 15/9/29.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//  https://github.com/wuwen1030/XTSafeCollection
//  https://github.com/allenhsu/NSDictionary-NilSafe

#import "ZDSafe.h"
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error "ZDSafe.m must be compiled with the (-fno-objc-arc) flag"
#endif

#if (ZD_LOG)
  #define ZDLOG(...) ZDLog(__VA_ARGS__)
#else
  #define ZDLOG(...)
#endif

void ZDLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);
void ZDLog(NSString *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
	NSLog(@"%@", content);
	va_end(ap);

	NSLog(@" ============= call stack ========== \n%@", [NSThread callStackSymbols]);
}

#pragma mark - Swizzle Function

static BOOL zd_swizzleInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
	Method origMethod = class_getInstanceMethod(aClass, originalSel);
	Method replMethod = class_getInstanceMethod(aClass, replacementSel);

	if (!origMethod || !replMethod) {
		if (!origMethod) ZDLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
        if (!replMethod) ZDLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), aClass);
		return NO;
	}

	if (class_addMethod(aClass, originalSel, method_getImplementation(replMethod), method_getTypeEncoding(replMethod))) {
		class_replaceMethod(aClass, replacementSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	}
	else {
		method_exchangeImplementations(origMethod, replMethod);
	}
	return YES;
}

static BOOL zd_swizzleClassMethod(Class zdClass, SEL originalSel, SEL replacementSel)
{
    Class aClass = object_getClass(zdClass);
    Method origMethod = class_getClassMethod(aClass, originalSel);
    Method replMethod = class_getClassMethod(aClass, replacementSel);
    if (!origMethod || !replMethod) {
        return NO;
    }
    method_exchangeImplementations(origMethod, replMethod);
    return YES;
}

///========================================================
#pragma mark - NSArray
///========================================================
@interface NSArray (ZDSafe)

@end

@implementation NSArray (ZDSafe)

- (id)zd_objectAtIndex:(NSUInteger)index
{
	if (index >= self.count) {
		ZDLog(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return nil;
	}

	return [self zd_objectAtIndex:index];
}

+ (id)zd_arrayWithObjects:(const id _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt
{
	id validObjects[cnt];

    NSUInteger count = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		if (objects[i]) {
			validObjects[count] = objects[i];
			count++;
		}
		else {
			ZDLOG(@"[%@ %@] NIL object at index {%lu}",
				NSStringFromClass([self class]),
				NSStringFromSelector(_cmd),
				(unsigned long)i);
		}
	}

	return [self zd_arrayWithObjects:objects count:cnt];
}

@end

///========================================================
#pragma mark - NSMutableArray
///========================================================
@interface NSMutableArray (ZDSafe)

@end

@implementation NSMutableArray (ZDSafe)

- (id)zd_objectAtIndex:(NSUInteger)index
{
	if (index >= self.count) {
		ZDLog(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return nil;
	}

	return [self zd_objectAtIndex:index];
}

- (void)zd_addObject:(id)anObject
{
	if (!anObject) {
		ZDLOG(@"[%@ %@], NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}
	[self zd_addObject:anObject];
}

- (void)zd_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	if (index >= self.count) {
		ZDLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_replaceObjectAtIndex:index withObject:anObject];
}

- (void)zd_insertObject:(id)anObject atIndex:(NSUInteger)index
{
	if (index > self.count) {
		ZDLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_insertObject:anObject atIndex:index];
}

@end

///========================================================
#pragma mark - NSDictionary
///========================================================
@interface NSDictionary (ZDSafe)

@end

@implementation NSDictionary (ZDSafe)

+ (instancetype)zd_dictionaryWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt
{
	id validObjects[cnt];
	id <NSCopying> validKeys[cnt];

    NSUInteger count = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		if (objects[i] && keys[i]) {
			validObjects[count] = objects[i];
			validKeys[count] = keys[i];
			count++;
		}
		else {
			ZDLOG(@"[%@ %@] NIL object or key at index{%lu}.",
				NSStringFromClass(self),
				NSStringFromSelector(_cmd),
				(unsigned long)i);
		}
	}

	return [self zd_dictionaryWithObjects:validObjects forKeys:validKeys count:count];
}

- (instancetype)zd_initWithObjects:(const id[])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    id validObjects[cnt];
    id <NSCopying> validKeys[cnt];
    
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i] && keys[i]) {
            validObjects[count] = objects[i];
            validKeys[count] = keys[i];
            count++;
        }
        else {
            ZDLOG(@"[%@ %@] NIL object or key at index{%lu}.",
                  NSStringFromClass(self),
                  NSStringFromSelector(_cmd),
                  (unsigned long)i);
        }
    }
    
    return [self zd_initWithObjects:objects forKeys:keys count:cnt];
}

@end

///========================================================
#pragma mark - NSMutableDictionary
///========================================================
@interface NSMutableDictionary (ZDSafe)

@end

@implementation NSMutableDictionary (ZDSafe)

- (void)zd_setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
	if (!aKey) {
		ZDLOG(@"[%@ %@] NIL key.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_setObject:anObject forKey:aKey];
}

@end

///========================================================
#pragma mark - NSObject
/// 处理不识别的selector
///========================================================
@interface NSObject (Forward)

@end

@implementation NSObject (Forward)

- (NSMethodSignature *)zd_methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [self zd_methodSignatureForSelector:aSelector];
    if (!signature) {
        NSString *selectorString = NSStringFromSelector(aSelector);
        NSUInteger parameterCount = [selectorString componentsSeparatedByString:@":"].count - 1;
        // Zero argument, forward to valueForKey:
        if (parameterCount == 0) {
            signature = [self zd_methodSignatureForSelector:@selector(valueForKey:)];
        }
        // One argument starting with set, forward to setValue:forKey:
        else if (parameterCount == 1 && [selectorString hasPrefix:@"set"]) {
            signature = [self zd_methodSignatureForSelector:@selector(setValue:forKey:)];
        }
    }
    return signature;
}

- (void)zd_forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selectorString = NSStringFromSelector(anInvocation.selector);
    NSUInteger parameterCount = [selectorString componentsSeparatedByString:@":"].count - 1;
    
    // get KVC
    if (parameterCount == 0) {
        __unsafe_unretained id value = [self valueForKey:NSStringFromSelector(anInvocation.selector)];
        [anInvocation setReturnValue:&value];
    }
    // set KVC
    else if (parameterCount == 1) {
        // The first parameter to an ObjC method is the third argument
        // ObjC methods are C functions taking instance and selector as their first two arguments
        __unsafe_unretained id value;
        [anInvocation getArgument:&value atIndex:2];
        
        // Get key name by converting setMyValue: to myValue
        id key = [NSString stringWithFormat:@"%@%@", [[selectorString substringWithRange:NSMakeRange(3, 1)] lowercaseString], [selectorString substringWithRange:NSMakeRange(4, selectorString.length - 5)]];
        [self setValue:value forKey:key];
    }
    else {
        [self zd_forwardInvocation:anInvocation];
    }
}

@end

///========================================================
#pragma mark - ZDSafe
#pragma mark -
///========================================================

@implementation ZDSafe

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // NSArray
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(zd_objectAtIndex:));
        zd_swizzleClassMethod([NSArray class], @selector(arrayWithObjects:count:), @selector(zd_arrayWithObjects:count:));
        
        // NSMutableArray
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(zd_objectAtIndex:));
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(zd_replaceObjectAtIndex:withObject:));
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:), @selector(zd_addObject:));
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:), @selector(zd_insertObject:atIndex:));
        
        // NSDictionary
        zd_swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:), @selector(zd_dictionaryWithObjects:forKeys:count:));
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSPlaceholderDictionary"), @selector(initWithObjects:forKeys:count:), @selector(zd_initWithObjects:forKeys:count:));
        
        // NSMutableDictionary
        zd_swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKey:), @selector(zd_setObject:forKey:));
        
        // Handle unrecognize selector
        zd_swizzleInstanceMethod([NSObject class], @selector(methodSignatureForSelector:), @selector(zd_methodSignatureForSelector:));
        zd_swizzleInstanceMethod([NSObject class], @selector(forwardInvocation:), @selector(zd_forwardInvocation:));
    });
}

@end
