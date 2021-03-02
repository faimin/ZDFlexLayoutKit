//
//  MMScrollView.h
//  MMUIDemo
//
//  Created by Zero.D.Saber on 2017/5/5.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDBannerScrollView;
@protocol ZDBannerScrollViewDelegate <NSObject>
@optional
- (void)scrollView:(ZDBannerScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;
- (void)scrollView:(ZDBannerScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;
// 如果你引入了SDWebImage则自动用SD下载，不用实现此协议；此协议方法是让用户自己调用非SD库下载用的
- (void)customDownloadWithImageView:(UIImageView *)imageView url:(NSString *)urlString placeHolderImage:(nullable UIImage *)placeHolderImage;
@end

@interface ZDBannerScrollView : UIView

@property (nonatomic, assign) NSTimeInterval interval;              ///< 定时器的间隔时间,默认2.5s
@property (nonatomic, strong) NSArray<NSString *> *imageURLStrings; ///< 图片地址数组
@property (nonatomic, assign) BOOL disableAutoScroll;               ///< 禁用自动的滚动

+ (instancetype)scrollViewWithFrame:(CGRect)frame
                           delegate:(nullable id<ZDBannerScrollViewDelegate>)delegate
                   placeholderImage:(nullable UIImage *)placeholderImage;

- (void)invalidateTimer;
- (void)pauseTimer;
- (void)resumeTimer;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
