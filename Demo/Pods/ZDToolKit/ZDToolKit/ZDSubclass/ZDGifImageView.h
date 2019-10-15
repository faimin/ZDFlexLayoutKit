//
//  ZDGifImageView.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/3.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDGifImageView : UIImageView

@property (nonatomic, strong) NSArray *imagePaths;///< 所有的图片路径,此方式不推荐(通过路径读写IO占用CPU较多)
@property (nonatomic, strong) NSArray *imageNames;///< 所有图片的名字
@property (nonatomic, assign) NSTimeInterval executeInterval; ///< 每次动画执行间隔,default = 1
@property (nonatomic, assign) NSInteger frameInterval; ///< 控制动画的执行速度，值越小越快

- (void)startAnimation;
- (void)stopAnimation;
- (void)pauseAnimation;

@end

NS_ASSUME_NONNULL_END
