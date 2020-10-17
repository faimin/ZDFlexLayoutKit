//
//  ReuseObject.h
//  DittyDemo
//
//  Created by Zero.D.Saber on 2017/5/9.
//  Copyright © 2017年 Zero. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZDPrepareForReuseProtocol <NSObject>

- (void)prepareForReuse;

@end

@interface ZDReusePool<__covariant ValueType> : NSObject

- (nullable ValueType)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)addReusePoolObject:(ValueType)object withIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
