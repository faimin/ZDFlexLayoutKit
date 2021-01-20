//
//  NSObject+ZDFLDeallocCallback.h
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2020/11/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZDFL_DisposeBlock)(id realTarget);

@interface NSObject (ZDFLDeallocCallback)

- (void)zdfl_deallocBlock:(ZDFL_DisposeBlock)deallocBlock;

@end

NS_ASSUME_NONNULL_END
