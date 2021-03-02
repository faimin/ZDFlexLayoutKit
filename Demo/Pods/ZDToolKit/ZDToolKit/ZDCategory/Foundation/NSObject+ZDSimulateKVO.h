//
//  NSObject+ZDSimulateKVO.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//@warning: don't use it with system's KVO together.
@interface NSObject (ZDSimulateKVO)

- (void)zd_addObserver:(id)observer forKey:(NSString *)key callbackBlock:(void(^)(id observer, NSString *key, id newValue))block;

- (void)zd_removeObserver:(id)observer forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
