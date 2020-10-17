//
//  ZDDefine.h
//  ZDUtility
//
//  Created by Zero on 15/8/18.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#ifndef ZDUtility_ZDDefine_h
#define ZDUtility_ZDDefine_h
#endif

#import <pthread.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//MARK:- 屏幕物理尺寸
//获取屏幕宽度、高度
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0 // 当前Xcode支持iOS8及以上
	#ifndef ZD_SCREEN_WIDTH
		#define ZD_SCREEN_WIDTH   ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)
	#endif
	
	#ifndef ZD_SCREENH_HEIGHT
		#define ZD_SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)
	#endif

	#ifndef ZD_SCREEN_SIZE
		#define ZD_SCREEN_SIZE    ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale, [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale) : [UIScreen mainScreen].bounds.size)
	#endif
#else
	#ifndef ZD_SCREEN_WIDTH
		#define ZD_SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
	#endif

	#ifndef ZD_SCREENH_HEIGHT
		#define ZD_SCREENH_HEIGHT ([UIScreen mainScreen].bounds.size.height)
	#endif

	#ifndef ZD_SCREEN_SIZE
		#define ZD_SCREEN_SIZE    ([UIScreen mainScreen].bounds.size)
	#endif
#endif

//MARK:- iPhone X
#define ZD_StatusBarHeight          (ZD_SCREENH_HEIGHT == 812.0 ? 44 : 20)     ///< 状态栏高度
#define ZD_FringeHeight             (ZD_SCREENH_HEIGHT == 812.0 ? 30 : 0)      ///< 刘海高度
#define ZD_SafeArea_NaviBarHeight   (ZD_SCREENH_HEIGHT == 812.0 ? 88 : 64)     ///< 导航栏高度
#define ZD_SafeArea_TabBarHeight    (ZD_SCREENH_HEIGHT == 812.0 ? 83 : 49)     ///< 标签栏高度
#define ZD_SafeArea_TopMargin       (ZD_SCREENH_HEIGHT == 812.0 ? 88 : 64)     ///< 导航栏高度
#define ZD_SafeArea_BottomMargin    (ZD_SCREENH_HEIGHT == 812.0 ? 34 : 0)      ///< 安全区域下方高度

//MARK:- Log
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
    #define ZDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define ZDLog(...) ((void)0)
#endif

//重写NSLog,Debug模式下打印日志和当前行数
///A better version of NSLog
//refer : http://onevcat.com/2014/01/black-magic-in-macro/
#ifdef DEBUG
#define NSLog(format, ...) 														\
do {                                                 							\
    fprintf(stderr, "<%s : %d> %s\n",                                           \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __PRETTY_FUNCTION__);                                             \
    (NSLog)((format), ##__VA_ARGS__);                                           \
    fprintf(stderr, "\n\n");                                                    \
} while (0)
#endif


//MARK:- 打印宏展开后的函数
#define __toString(x) __toString_0(x)
#define __toString_0(x) #x
#define ZDLOG_MACRO(x) NSLog(@"%s=\n%s", #x, __toString(x))

//MARK:- Alert
//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
  #define ZD_AlertLog(fmt, ...) {UIAlertView *alert = [[UIAlertView alloc]	\
							  initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
  #define ZD_AlertLog(...)     ((void)0)
#endif

#define ZD_Assert(condition, ...)														\
	do {																				\
		if (!(condition))																\
		{																				\
			[[NSAssertionHandler currentHandler]										\
			handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]	\
			file:[NSString stringWithUTF8String:__FILE__]								\
			lineNumber:__LINE__															\
			description:__VA_ARGS__];													\
		}																				\
	} while (0)


//获取当前语言
#define ZD_CurrentLanguage	([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//MARK:- 版本判断
//获取系统版本
#define ZD_SYSTEMVERSION    [[[UIDevice currentDevice] systemVersion] floatValue]

#define SYSTEM_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)					([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] != NSOrderedDescending)


//MARK:- 释放
#if !__has_feature(objc_arc)
	//释放一个对象
	#define ZD_SAFE_RELEASE(P)	  \
		if (P)					  \
		{						  \
			[P release], P = nil; \
		}
#endif

//MARK:- 单例
//----------------------单例----------------------------

#ifndef SHARED_SERVICE
  #define SHARED_SERVICE(ServiceName)					 \
	+ (instancetype)sharedInstance						 \
	{													 \
		static ServiceName *sharedInstance;				 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			sharedInstance = [[ServiceName alloc] init]; \
		});												 \
		return sharedInstance;							 \
	}
#endif

//-----------------------------------------------------

/**
 *******************************************************
 *  此单例支持ARC以及非MRC环境
 *
 *  使用说明
 *  1. 创建你的单例 比如我这里创建的是 SharedMaxTools
 *  2. 在.h文件添加  singleton_h(MaxTools)
 *  3. 在.m文件添加
 *
 *  - (instancetype)init
 *  {
 *  static dispatch_once_t onceToken;
 *  static id obj = nil;
 *  dispatch_once(&onceToken, ^{
 *  obj = [super init];
 *  if (obj) {
 *
 *  // 加载资源
 *
 *  }
 *  });
 *  return self;
 *  }
 *  singleton_m(MaxTools);
 *
 *******************************************************
 */

// ## : 连接字符串和参数
#define Singleton_h(name) + (instancetype)shared##name;

#if __has_feature(objc_arc) // ARC
  #define singleton_m(name)								 \
	static id _instance;								 \
	+ (instancetype)allocWithZone:(struct _NSZone *)zone \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [super allocWithZone:zone];		 \
		});												 \
		return _instance;								 \
	}													 \
														 \
	+ (instancetype)shared##name						 \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [[self alloc] init];			 \
		});												 \
		return _instance;								 \
	}													 \
	+ (instancetype)copyWithZone:(struct _NSZone *)zone	 \
	{													 \
		return _instance;								 \
	}													 \
	+ (instancetype)new									 \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [[self alloc] init];			 \
		});												 \
		return _instance;								 \
	}

#else                       // MRC

  #define singleton_m(name)								\
	static id _instance;								\
	+ (id)allocWithZone:(struct _NSZone *)zone			\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [super allocWithZone:zone];		\
		});												\
		return _instance;								\
	}													\
														\
	+ (instancetype)shared##name						\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [[self alloc] init];			\
		});												\
		return _instance;								\
	}													\
														\
	- (oneway void)release								\
	{													\
														\
	}													\
														\
	- (instancetype)autorelease							\
	{													\
		return _instance;								\
	}													\
														\
	- (instancetype)retain								\
	{													\
		return _instance;								\
	}													\
														\
	- (NSUInteger)retainCount							\
	{													\
		return 1;										\
	}													\
														\
	+ (instancetype)copyWithZone:(struct _NSZone *)zone	\
	{													\
		return _instance;								\
	}													\
	+ (instancetype)new									\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [[self alloc] init];			\
		});												\
		return _instance;								\
	}
#endif


//MARK:- 读取本地图片
#define ZD_BUNDLEIMAGE(file, type)	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]
//定义UIImage对象
#define ZD_IMAGENAMED(_imageName)	[UIImage imageNamed:@#_imageName]


//MARK:- RGB
/// RGB颜色转换（16进制->10进制）
///  Create UIColor with a hex string.
///
///  Example: self.backgroundColor = ZD_UIColorFromHEX(f9f9f9);
#define ZD_UIColorFromHEX(hexValue)                                         \
[UIColor colorWithRed:((float)((0x##hexValue & 0xFF0000) >> 16)) / 255.0    \
                green:((float)((0x##hexValue & 0xFF00) >> 8)) / 255.0       \
                 blue:((float)(0x##hexValue & 0xFF)) / 255.0                \
                alpha: 1.0]

// 获取RGB颜色
#define ZD_RGBA(r, g, b, a)	[UIColor colorWithRed: r / 255.0f green: g / 255.0f blue: b / 255.0f alpha: a]
#define ZD_RGB(r, g, b)		ZD_RGBA(r, g, b, 1.0f)


//程序的本地化,引用国际化的文件
#define ZD_LOCAL(x, ...)				NSLocalizedString(x, nil)

//MARK:- GCD
#define ZD_GLOBAL_QUEUE(block)  	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define ZD_MAIN_QUEUE(block)		dispatch_async(dispatch_get_main_queue(), block)
#define ZD_CREATE_SERIAL_QUEUE(_label, QOS_CLASS_DEFAULT)    dispatch_queue_create(#_label, dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0))
#define ZD_CREATE_CONCURRENT_QUEUE(_label, QOS_CLASS_DEFAULT)   dispatch_queue_create(#_label, dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0))

//MARK:- 由角度获取弧度/弧度获取角度
#define ZD_DegreesToRadian(x)          (M_PI * (x) / 180.0)
#define ZD_RadianToDegrees(radian)     ((radian * 180.0) / (M_PI))

//MARK:- Kindof
#define ZD_IS_KIND_OF_CLASS(obj_, Class_) [obj_ isKindOfClass:NSClassFromString(@#Class_)]

//MARK:- URL
#define ZD_URL(urlString_) [NSURL URLWithString:urlString_]

//MARK:- TODO
//(http://blog.sunnyxx.com/2015/03/01/todo-macro/)
#define STRINGIFY(S) #S                             // 转成字符串
#define DEFER_STRINGIFY(S) STRINGIFY(S)             // 需要解两次才解开的宏
#define PRAGMA_MESSAGE(MSG) _Pragma(STRINGIFY(message(MSG)))
#define FORMATTED_MESSAGE(MSG) "[TODO-" DEFER_STRINGIFY(__COUNTER__) "] " MSG " \n" DEFER_STRINGIFY(__FILE__) " line " DEFER_STRINGIFY(__LINE__)   // 为warning增加更多信息
#define KEYWORDIFY try {} @catch (...) {}           // 使宏前面可以加@
#define TODO(MSG) KEYWORDIFY PRAGMA_MESSAGE(FORMATTED_MESSAGE(MSG))// 最终使用的宏

//MARK:- 超出作用域后执行
//defer(swift延迟调用关键字)宏 (http://blog.sunnyxx.com/2014/09/15/objc-attribute-cleanup/ )
/// 注意`ZD_CleanupBlock`函数的入参是`cleanup`所修饰变量的地址,类型要一样
NS_INLINE void ZD_CleanupBlock(__strong void(^*executeCleanupBlock)(void)) {
    (*executeCleanupBlock)();
}

/// 出了作用域时执行block,类似于swift中的defer和EXTScope中的onExit
///
/// Example:
/// zd_defer {
///    /// 所谓作用域结束，包括大括号结束、return、goto、break、exception等各种情况
///    NSLog(@"当前作用域结束,马上要出作用域了");
/// };
///
/// 加了个`unused`的attribute用来消除`unused variable`的warning
/// 注意`ZD_CleanupBlock`函数的入参是所修饰变量的地址,类型要一样
#ifndef zd_defer
	#define zd_defer  \
        zd_keywordify \
        __strong void(^executeCleanupBlock)(void) __attribute__((cleanup(ZD_CleanupBlock), unused)) = ^
#endif

//MARK:- 弱引用
#ifndef zd_keywordify
    #if DEBUG
        #define zd_keywordify @autoreleasepool {}
    #else
        #define zd_keywordify @try {} @catch (...) {}
    #endif
#endif

#ifndef zd_weakTarget
#define zd_weakTarget(objc_)  \
zd_keywordify __weak __typeof__(objc_) weak##_##objc_ = (objc_);
#endif

#ifndef zd_strongTarget
#define zd_strongTarget(objc_)  \
zd_keywordify __strong __typeof__(weak##_##objc_) objc_ = weak##_##objc_;
#endif

//MARK:- main函数之前执行
#define ZD_ExcuteBeforeMainFunction __attribute__((constructor))

//MARK:- 类型推断
// https://pspdfkit.com/blog/2017/even-swiftier-objective-c/ && https://medium.com/@maicki/type-inference-with-auto-type-55a38ef56372
#if defined(__cplusplus)
#define zdlet auto const
#else
#define zdlet __auto_type const
#endif

#if defined(__cplusplus)
#define zdvar auto
#else
#define zdvar __auto_type
#endif

//MARK:- KeyPath
#if DEBUG
#define ZD_KEYPATH(object, property) ((void)(NO && ((void)object.property, NO)), @#property)
#else
#define ZD_KEYPATH(object, property) @#property
#endif


//MARK:- 警告消除
/// 消除performSelector警告
#define ZD_SuppressPerformSelectorLeakWarning(...)                      \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除deprecated方法的警告
#define ZD_SuppressDeprecatedWarning(...)                               \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")   \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除定义未使用变量的警告
#define ZD_SuppressUnusedVariableWarning(...)                           \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wunused-variable\"")           \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除使用不存在的方法名的警告
#define ZD_SuppressUndeclaredSelectorWarning(...)                       \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")       \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除不兼容指针类型的警告
#define ZD_SuppressIncompatiblePointerTypeWarning(...)                  \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wincompatible-pointer-types\"")\
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除block不定个数 个参数的警告
#define ZD_SuppressNotPrototypeWarning(...)                             \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wstrict-prototypes\"")         \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);

/// 消除函数不适合的警告
#define ZD_SuppressNotAvailableWarning(...)                             \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wpartial-availability\"")      \
    __VA_ARGS__;                                                        \
    _Pragma("clang diagnostic pop")                                     \
} while (0);




































