//
//  ZDInvocationWrapper.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDInvocationWrapper<__covariant R : id> : NSObject

+ (R)zd_target:(id)target invokeSelectorWithArgs:(SEL)selector, ...;

+ (R)zd_target:(id)target invokeSelector:(SEL)selector args:(va_list)args;

@end

NS_ASSUME_NONNULL_END
