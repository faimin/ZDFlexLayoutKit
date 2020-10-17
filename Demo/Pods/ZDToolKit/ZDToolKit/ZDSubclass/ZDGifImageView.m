//
//  ZDGifImageView.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/3.
//
//

#import "ZDGifImageView.h"
#import "ZDProxy.h"

static NSUInteger m = 0;
static NSMutableArray *imagesArr;

@interface ZDGifImageView () <CAAnimationDelegate>

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation ZDGifImageView

- (void)dealloc {
    [imagesArr removeAllObjects];
    imagesArr = nil;
    [self stopAnimation];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    m = 0;
}

#pragma mark - Public

- (void)startAnimation {
    [self stopAnimation];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startKeyframeAni) withObject:nil afterDelay:.2];
}

- (void)startKeyframeAni {
    NSMutableArray *images = @[].mutableCopy;
    NSMutableArray *numbers = @[].mutableCopy;
    
    CGFloat last = 0.f;
    for (int i = 0; i < self.imageNames.count; i++) {
        id cgi = (__bridge id)[UIImage imageNamed:self.imageNames[i]].CGImage;
        [images addObject:cgi];
        NSNumber *n;
        
        if (i < 12) {
            n = @(last + 0.005);
        } else if (i < self.imageNames.count - 1) {
            n = @(last + 0.008389);
        } else {
            n = @1;
        }
        last = n.floatValue;
        [numbers addObject:n];
    }
    
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animation];
    [ani setKeyPath:@"contents"];
    [ani setValues:images];
    [ani setKeyTimes:numbers];
    [ani setRepeatCount:CGFLOAT_MAX];
    [ani setDelegate:self];
    
    CGFloat t = 5.96;
    ani.duration = t;
    
    [self.layer addAnimation:ani forKey:@"cus"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    UIImage *i = [UIImage imageNamed:self.imageNames.firstObject];
    self.image = i;
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    _displayLink = nil;
    [self.layer removeAllAnimations];
}

- (void)pauseAnimation {
    self.displayLink.paused = YES;
}

#pragma mark -

- (void)displayExecute:(CADisplayLink *)displayLink {
    m++;
    NSUInteger imageCount = self.imageNames.count ?: self.imagePaths.count;
    NSUInteger i = m % imageCount;
    // 每秒执行次数 * 时间间隔
    NSUInteger duration = (60 / displayLink.frameInterval) * (self.executeInterval ?: 1);
    
    if (i <= 12) {
        displayLink.frameInterval = 2;
    } else {
        displayLink.frameInterval = 3;
    }
    
    if (m < imageCount) {
        UIImage *image;
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

#pragma mark - Getter

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        ZDWeakProxy *weakSelf = [ZDWeakProxy proxyWithTarget:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(displayExecute:)];
        _displayLink.frameInterval = self.frameInterval ?: 1;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

@end
