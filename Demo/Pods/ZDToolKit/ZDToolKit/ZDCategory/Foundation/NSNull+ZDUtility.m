//
//  NSNull+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/3/22.
//

#import "NSNull+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSNull_ZDUtility)

@implementation NSNull (ZDUtility)

#pragma mark - Forward Message

// 未识别的方法进入消息转发，把消息转发给 nil
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        NSArray<NSString *> *stackArray = NSThread.callStackSymbols;
        NSError *parserError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stackArray options:NSJSONWritingPrettyPrinted error:&parserError];
        if (!parserError) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"stackJsonString = %@", jsonString);
        }
        NSCAssert(NO, @"对象类型错了");
        
        signature = [NSObject instanceMethodSignatureForSelector:@selector(init)];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

@end
