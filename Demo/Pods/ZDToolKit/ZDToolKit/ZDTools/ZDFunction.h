//
//  ZDFunction.h
//  ZDUtility
//
//  Created by Zero on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//#pragma clang diagnostic ignored "-Wstrict-prototypes"

typedef NS_ENUM(NSInteger, ZDThrottleType) {
    ZDThrottleType_Invoke_First,
    ZDThrottleType_Invoke_Last,
};

//===============================================================

#pragma mark - Gif Image
#pragma mark -
/// Loads an animated GIF from file, compatible with UIImageView
UIKIT_EXTERN UIImage *ZD_AnimatedGIFFromFile(NSString *path);

/// Loads an animated GIF from data, compatible with UIImageView
UIKIT_EXTERN UIImage *ZD_AnimatedGIFFromData(NSData *data);


//===============================================================

#pragma mark - Image
#pragma mark -

UIKIT_EXTERN UIImage *ZD_TintedImageWithColor(UIColor *tintColor, UIImage *image);

///  制作缩略图
///  @param url       图片本地地址
///  @param imageSize 图片的宽或高
///  @return 生成的缩略图
UIKIT_EXTERN UIImage *ZD_ThumbnailImageFromURl(NSURL *url, int imageSize);

///  获取图片格式
///  @param data 图片数据
///  @return 格式字符串
FOUNDATION_EXPORT NSString *ZD_TypeForImageData(NSData *data);
FOUNDATION_EXPORT NSString *ZD_TypeForData(NSData *data);

///  高斯模糊图片
///  @param image 原始图片
///  @param blur  高斯比例（0->1）
///  @return 高斯图片
UIKIT_EXTERN UIImage *ZD_BlurImageWithBlurPercent(UIImage *image, CGFloat blur);

//===============================================================

#pragma mark - UIView
#pragma mark -
/// @brief 画虚线
/// @param lineFrame    虚线的frame
/// @param lineLength   虚线中短线的宽度
/// @param lineSpacing  虚线中短线之间的间距
/// @param lineColor    虚线中短线的颜色
UIKIT_EXTERN UIView *ZD_CreateDashedLineWithFrame(CGRect lineFrame, int lineLength, int lineSpacing, UIColor *lineColor);

/// @brief 给视图添加一个镂空的遮罩(圆角效果)
/// @param view       需要添加镂空layer的视图
/// @param size       镂空layer的尺寸,默认为view的尺寸
/// @param fillColor  镂空layer的填充颜色(边缘色),默认为白色
UIKIT_EXTERN void ZD_AddHollowoutLayerToView(__kindof UIView *view, CGSize size, UIColor *fillColor);

/// 打印view的坐标系信息
UIKIT_EXTERN void ZD_PrintViewCoordinateInfo(__kindof UIView *view);

#pragma mark - String
#pragma mark -
///  设置文字行间距
///  @param string    原始字符串
///  @param lineSpace 行间距
///  @param fontSize  字体大小
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *ZD_SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

///  设置某字符串为特定颜色和大小
///  @param orignString  原始字符串
///  @param filterString 指定的字符串
///  @param filterColor  指定的颜色
///  @param filterFont   指定字体
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *ZD_SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor, __kindof UIFont *filterFont);
///  在文字中添加图片
///  @param image 图片
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *ZD_AddImageToAttributeString(UIImage *image);

FOUNDATION_EXPORT NSString *ZD_URLEncodedString(NSString *sourceText);
FOUNDATION_EXPORT CGFloat ZD_HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth);
FOUNDATION_EXPORT CGFloat ZD_WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight);

///  计算文字的大小
///  @param sourceString 原始字符串
///  @param font         字体(默认为系统字体)
///  @param maxWidth     约束宽高度，约束宽度时高度设为0，约束高度时宽度设为0即可
///  @param maxHeight    约束宽高度，约束宽度时高度设为0，约束高度时宽度设为0即可
///  @return CGSize
FOUNDATION_EXPORT CGSize ZD_SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight);

/// 反转字符串
FOUNDATION_EXPORT NSString *ZD_ReverseString(NSString *sourceString);
FOUNDATION_EXPORT BOOL ZD_IsEmptyString(NSString *string);
FOUNDATION_EXPORT BOOL ZD_IsEmptyOrNilString(NSString *string);
/// 获取字符串(或汉字)首字母
FOUNDATION_EXPORT NSString *ZD_FirstCharacterWithString(NSString *string);
/// 将字符串数组按照元素首字母顺序进行排序分组
FOUNDATION_EXPORT NSDictionary *ZD_DictionaryOrderByCharacterWithOriginalArray(NSArray<NSString *> *array);

FOUNDATION_EXPORT BOOL ZD_VideoIsPlayable(NSString *urlString);

//===============================================================

#pragma mark - InterfaceOrientation
#pragma mark -
/// 屏幕是横屏还是竖屏
FOUNDATION_EXPORT BOOL ZD_isPortrait(void);     ///< 横屏
FOUNDATION_EXPORT BOOL ZD_isLandscape(void);    ///< 竖屏

#pragma mark - NSBundle
#pragma mark -
/// get list of classes already loaded into memory in specific bundle (or binary)
FOUNDATION_EXPORT NSArray *ZD_GetClassNames(void);

//===============================================================

#pragma mark - Device
#pragma mark -
FOUNDATION_EXPORT BOOL ZD_isRetina(void);
FOUNDATION_EXPORT BOOL ZD_isPad(void);
FOUNDATION_EXPORT BOOL ZD_isSimulator(void);
FOUNDATION_EXPORT BOOL ZD_isJailbroken(void);
FOUNDATION_EXPORT BOOL ZD_isSetProxy(void);
FOUNDATION_EXPORT double ZD_SystemVersion(void);
FOUNDATION_EXPORT CGFloat ZD_Scale(void);
FOUNDATION_EXPORT CGSize ZD_ScreenSize(void);
FOUNDATION_EXPORT CGFloat ZD_ScreenWidth(void);
FOUNDATION_EXPORT CGFloat ZD_ScreenHeight(void);
FOUNDATION_EXPORT BOOL ZD_iPhone4s(void);
FOUNDATION_EXPORT BOOL ZD_iPhone5s(void);
FOUNDATION_EXPORT BOOL ZD_iPhone6(void);
FOUNDATION_EXPORT BOOL ZD_iPhone6p(void);
FOUNDATION_EXPORT BOOL ZD_iPhoneX(void);

/// 获取 app 的 icon 图标名称
FOUNDATION_EXPORT NSString *ZD_IconName(void);
FOUNDATION_EXPORT NSString *ZD_LaunchImageName(void);

/// 获取设备MAC地址
FOUNDATION_EXPORT NSString *ZD_MacAddress(void);
/// 数组两个值，第一个是本地地址，127.0.0.1也就是localhost，
/// 第二个是路由器DNS分配的公网地址。
FOUNDATION_EXPORT NSArray *ZD_IPAddresses(void);
/// 获取当前的内存使用情况
FOUNDATION_EXPORT double ZD_MemoryUsage(void);

#pragma mark - Function
#pragma mark -
/// 处理精度问题: num * (10^num_digits) / (10^num_digits)
FOUNDATION_EXPORT double ZD_Round(CGFloat num, NSInteger num_digits);
/// Int转NSData
FOUNDATION_EXPORT NSData *ZD_ConvertIntToData(int value);
/// 随机色
FOUNDATION_EXPORT UIColor *ZD_RandomColor(void);

#pragma mark - GCD
#pragma mark -
FOUNDATION_EXPORT void ZD_Dispatch_async_on_main_queue(dispatch_block_t block);
FOUNDATION_EXPORT void ZD_Dispatch_sync_on_main_queue(dispatch_block_t block);
/// 判断当前是不是主队列
FOUNDATION_EXPORT BOOL ZD_IsMainQueue(void);
/// 让某一方法在固定的时间间隔内只执行一次
FOUNDATION_EXPORT void ZD_Dispatch_throttle_on_mainQueue(ZDThrottleType throttleType, NSTimeInterval intervalInSeconds, dispatch_block_t block);
FOUNDATION_EXPORT void ZD_Dispatch_throttle_on_queue(ZDThrottleType throttleType, NSTimeInterval intervalInSeconds, dispatch_queue_t queue, dispatch_block_t block);
/// 根据当前活跃的处理器个数来创建队列
FOUNDATION_EXPORT dispatch_queue_t ZD_TaskQueue(void);

#pragma mark - Runtime
#pragma mark -
FOUNDATION_EXPORT void ZD_PrintObjectMethods(void);
FOUNDATION_EXPORT void ZD_SwizzleClassSelector(Class aClass, SEL originalSelector, SEL newSelector);
FOUNDATION_EXPORT void ZD_SwizzleInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector);
FOUNDATION_EXPORT IMP  ZD_SwizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP);
FOUNDATION_EXPORT BOOL ZD_SwizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP, IMP *orignalStoreIMP);
/// 判断selector是否属于某一protocol
FOUNDATION_EXPORT BOOL ZD_ProtocolContainSel(Protocol *protocol, SEL sel);






