//
//  UIImageView+ZDGIF.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/6/29.
//
//

#import "UIImageView+ZDGIF.h"
#import <objc/runtime.h>
#import "ZDProxy.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(UIImageView_ZDGIF)

static NSUInteger m = 0;

const void *DisplayLinkKey = &DisplayLinkKey;
const void *ImageNamesKey = &ImageNamesKey;
const void *ImagePathsKey = &ImagePathsKey;
const void *ExecuteIntervalKey = &ExecuteIntervalKey;
const void *FrameIntervalKey = &FrameIntervalKey;

@interface UIImageView ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation UIImageView (ZDGIF)

#pragma mark - Public

- (void)startAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startTimer];
    });
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark -

- (void)displayExecute:(CADisplayLink *)displayLink {
    ++m;
    NSUInteger imageCount = self.imageNames.count ?: self.imagePaths.count;
    NSUInteger i = m % imageCount;
    // 每秒执行次数 * 时间间隔
    NSUInteger duration = (60 / displayLink.frameInterval) * (self.executeInterval ?: 1);
    
    if (m < imageCount) {
        UIImage *image = nil;
        if (self.imageNames && self.imageNames.count > i) {
            image = [UIImage imageNamed:self.imageNames[i]];
        }
        else if (self.imagePaths && self.imagePaths.count > i) {
            image = [UIImage imageWithContentsOfFile:self.imagePaths[i]];
        }
        self.image = image;
    } else if (m >= imageCount + duration) {
        m = 0;
    }
}

- (void)startTimer {
    self.displayLink.paused = NO;
}

#pragma mark - Property

- (void)setDisplayLink:(CADisplayLink *)displayLink {
    objc_setAssociatedObject(self, DisplayLinkKey, displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CADisplayLink *)displayLink {
    CADisplayLink *displayLink = objc_getAssociatedObject(self, DisplayLinkKey);
    if (!displayLink) {
        ZDWeakProxy *weakSelf = [ZDWeakProxy proxyWithTarget:self];
        displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(displayExecute:)];
        displayLink.frameInterval = self.frameInterval ?: 1;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        displayLink.paused = YES;
        self.displayLink = displayLink;
    }
    return displayLink;
}

- (void)setImageNames:(NSArray<NSString *> *)imageNames {
    objc_setAssociatedObject(self, ImageNamesKey, imageNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)imageNames {
    return objc_getAssociatedObject(self, ImageNamesKey);
}

- (void)setImagePaths:(NSArray<NSString *> *)imagePaths {
    objc_setAssociatedObject(self, ImagePathsKey, imagePaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)imagePaths {
    return objc_getAssociatedObject(self, ImagePathsKey);
}

- (void)setExecuteInterval:(NSTimeInterval)executeInterval {
    objc_setAssociatedObject(self, ExecuteIntervalKey, @(executeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)executeInterval {
    return [objc_getAssociatedObject(self, ExecuteIntervalKey) doubleValue];
}

- (void)setFrameInterval:(NSInteger)frameInterval {
    objc_setAssociatedObject(self, FrameIntervalKey, @(frameInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)frameInterval {
    return [objc_getAssociatedObject(self, FrameIntervalKey) integerValue];
}

@end
