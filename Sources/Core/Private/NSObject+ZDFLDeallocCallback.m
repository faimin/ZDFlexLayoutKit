//
//  NSObject+ZDFLDeallocCallback.m
//  ZDFlexLayoutKit
//
//  Created by Zero.D.Saber on 2020/11/29.
//

#import "NSObject+ZDFLDeallocCallback.h"
#import <objc/runtime.h>

@interface ZDFLTaskBlockExecutor : NSObject

@property (nonatomic, copy, readonly) ZDFL_DisposeBlock deallocBlock;
@property (nonatomic, unsafe_unretained, readonly) id realTarget;

- (instancetype)initWithBlock:(ZDFL_DisposeBlock)deallocBlock realTarget:(id)realTarget;

@end

@implementation ZDFLTaskBlockExecutor

- (void)dealloc {
    if (nil != self.deallocBlock) {
        self.deallocBlock(self);
        _deallocBlock = nil;
    }
}

- (instancetype)initWithBlock:(ZDFL_DisposeBlock)deallocBlock realTarget:(id)realTarget {
    if (self = [super init]) {
        //属性设为readonly,并用指针指向方式,是参照RACDynamicSignal中的写法
        self->_deallocBlock = [deallocBlock copy];
        self->_realTarget = realTarget;
    }
    return self;
}

@end

#pragma mark -

@implementation NSObject (ZDFLDeallocCallback)

- (void)zdfl_deallocBlock:(ZDFL_DisposeBlock)deallocBlock {
    if (!deallocBlock) return;
    
    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, _cmd);
    if (!deallocBlocks) {
        deallocBlocks = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    
    ZDFLTaskBlockExecutor *blockExecutor = [[ZDFLTaskBlockExecutor alloc] initWithBlock:deallocBlock realTarget:self];
    [deallocBlocks addObject:blockExecutor];
}

@end
