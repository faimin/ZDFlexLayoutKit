//
//  UIImageView+ZDGIF.h
//  Pods
//
//  Created by MOMO on 2017/6/29.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (ZDGIF)

@property (nonatomic, strong) NSArray<NSString *> *imagePaths;///< 所有的图片路径(此方式不推荐通过路径读写IO占用CPU较多,耗电）
@property (nonatomic, strong) NSArray<NSString *> *imageNames;///< 所有图片的名字
@property (nonatomic, assign) NSTimeInterval executeInterval; ///< 每次动画执行间隔,default = 1
@property (nonatomic, assign) NSInteger frameInterval;   ///< 控制动画的执行速度,值越小越快

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
