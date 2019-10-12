//
//  ZDFlexLayoutDiv.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/11.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "ZDFlexLayoutDiv.h"
#import <objc/runtime.h>
#import "YGLayoutM+Private.h"

@implementation ZDFlexLayoutDiv
@synthesize yoga = _yoga, layoutFrame = _layoutFrame, parent = _parent, children = _children;

#pragma mark - ZDFlexLayoutNodeProtocol

- (void)addChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)]) {
        [self.children addObject:child];
    }
    else {
        NSCAssert1(NO, @"不支持此类型：%@", child);
    }
}

- (void)removeChild:(ZDFlexLayoutView)child {
    if ([child conformsToProtocol:@protocol(ZDFlexLayoutDivProtocol)] && [self.children containsObject:child]) {
        [self.children removeObject:child];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return size;
}

//MARK: Property
- (YGLayoutM *)yoga {
    if (!_yoga) {
        _yoga = [[YGLayoutM alloc] initWithView:self];
        _yoga.isEnabled = YES;
    }
    return _yoga;
}

- (NSMutableOrderedSet<ZDFlexLayoutView> *)children {
    if (!_children) {
        _children = [NSMutableOrderedSet orderedSet];
    }
    return _children;
}

@end
