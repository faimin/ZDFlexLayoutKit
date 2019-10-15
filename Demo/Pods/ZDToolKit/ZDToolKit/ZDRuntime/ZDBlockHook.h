//
//  ZDBlock.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import <Foundation/Foundation.h>

//################################################################
#pragma mark - ------------------------------- 方案1 ==> MessageForward ----------------------------------

typedef void * ZDBlockIMP;

/// 获取block的typeCoding
FOUNDATION_EXPORT const char *ZD_BlockSignatureTypes(id block);

/// 获取block的函数指针(这种方式获取的函数指针,当调用执行时,第一参数为block自己,后面才是block的参数类型)
FOUNDATION_EXPORT ZDBlockIMP ZD_BlockInvokeIMP(id block);

/// 获取msg_forward函数指针
FOUNDATION_EXPORT IMP ZD_MsgForwardIMP(const char *methodTypes);

/// 判断当前函数指针是否指向的msg_froward
FOUNDATION_EXPORT BOOL ZD_IsMsgForwardIMP(IMP imp);

/// 简化block方法签名
FOUNDATION_EXPORT NSString *ZD_ReduceBlockSignatureCodingType(const char *signatureCodingType);

/// 打印block参数(消息转发实现)
/// @return 返回一个新的block
/// @note IMP的第一个参数是block自己，剩余的参数是参数列表中的参数，不存在selector
FOUNDATION_EXPORT id ZD_HookBlock(id block);


//*************************************************************
#pragma mark - ------------------------------- 方案2 ==> Libffi ----------------------------------
#pragma mark -
//*************************************************************

#define USE_LIBFFI (__has_include(<ffi.h>) || __has_include("ffi.h"))

#if USE_LIBFFI
/// 利用libffi实现
@interface ZDFfiBlockHook : NSObject

+ (instancetype)hookBlock:(id)block;

@end
#endif


//*************************************************************
#pragma mark - ---------------------- 整合 -----------------------
#pragma mark -

typedef NS_ENUM(NSInteger, ZDHookWay) {
    ZDHookWay_MsgForward = 0,
    ZDHookWay_Libffi     = 1,
};

@interface NSObject (ZDHookBlock)

- (void)zd_hookBlock:(id *)block hookWay:(ZDHookWay)hookWay;

@end

//*************************************************************
