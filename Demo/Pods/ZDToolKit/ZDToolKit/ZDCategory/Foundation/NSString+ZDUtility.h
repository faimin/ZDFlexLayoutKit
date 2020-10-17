//
//  NSString+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 15/12/26.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZDRegex) {
    ZDRegex_PhoneNumber = 1,        ///< 手机号
    ZDRegex_SMSVerifyCode,          ///< 短信验证码(6位纯数字的格式)
    ZDRegex_Nickname,               ///< 昵称(只能由中文、字母或数字组成)
    ZDRegex_Password,               ///< 密码(长度应为6-16个字符,密码必须包含字母和数字)
    ZDRegex_RealName,               ///< 实名认证(汉字)
    ZDRegex_Email,                  ///< 邮箱
};

static NSString * _Nonnull const ZDRegexStr[] = {
    //@"^(0|86|17951)?(13[0-9]|14[57])[0-9]{8}|15[012356789]|17[678]|18[0-9]$"
    [ZDRegex_PhoneNumber] = @"^1[34578]\\d{9}$",
    [ZDRegex_SMSVerifyCode] = @"^\\d{6}$",
    [ZDRegex_Nickname] = @"^[A-Za-z0-9\u4e00-\u9fa5]{3,20}$",
    [ZDRegex_Password] = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,16}",
    [ZDRegex_RealName] = @"^[\u4E00-\u9FA5]{2,4}$",
    [ZDRegex_Email] = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}",
};

//=================================================
NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZDUtility)

// MARK: Size
/// 宽和高都是0的时候为默认值CGFloat_MAX
- (CGFloat)zd_widthWithFont:(UIFont *)font;
- (CGFloat)zd_heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGFloat)zd_widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
- (CGSize)zd_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGSize)zd_sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)needSize;

- (CGSize)zd_sizeWithFont:(UIFont *)font
       constrainedToWidth:(CGFloat)width
                lineSpace:(CGFloat)lineSpace;
- (CGSize)zd_sizeWithFont:(UIFont *)customFont
        constrainedToSize:(CGSize)size
                lineSpace:(CGFloat)lineSpace;
- (CGSize)zd_sizeWithFont:(UIFont *)customFont
        constrainedToSize:(CGSize)size
                lineSpace:(CGFloat)lineSpace
    limiteToNumberOfLines:(NSUInteger)numberOfLines;

// MARK: Emoji
- (BOOL)zd_isContainsEmoji;
- (NSString *)zd_filterEmoji;
- (NSString *)zd_removeHalfEmoji;
- (NSString *)zd_subEmojiStringToIndex:(NSUInteger)index;   ///< 安全截取包含emoji的文本

// MARK: Function
- (NSString *)zd_reservedNumberOnly;   ///< 只保留数字
- (NSString *)zd_reverse;              ///< 反转字符串
- (BOOL)zd_isContainString:(NSString *)string;
- (BOOL)zd_isContainChinese;
- (BOOL)zd_isAllChinse;
- (BOOL)zd_isAllNumber;
- (BOOL)zd_isEmptyOrNil;
- (BOOL)zd_isEmpty;
- (NSUInteger)zd_countForTargetString:(NSString *)targetString; ///< 包含的指定字符串的个数
- (NSUInteger)zd_wordCount;
- (NSString *)zd_hexString;
- (NSString *)zd_md5String;

// MARK: Validate(Regex)
- (BOOL)zd_isValidWithRegex:(ZDRegex)regex;
- (BOOL)zd_isValidEmail;
- (BOOL)zd_isValidIdCard;
- (BOOL)zd_isValidCardNo;

// MARK: JSON
- (nullable NSDictionary *)zd_dictionaryValue;
+ (nullable NSString *)zd_stringValueFromJson:(id)arrayOrDic;

// MARK: HTML
- (NSString *)zd_decodeHTMLCharacterEntities;
- (NSString *)zd_encodeHTMLCharacterEntities;
- (NSString *)zd_stringByTrimHTML;
- (NSString *)zd_stringByTrimScriptAndHTML;

// MARK: Decode && Encode
- (nullable NSString *)zd_stringByAddingPercentEncodingForRFC3986;
- (NSString *)zd_stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace;
- (NSString *)zd_stringByURLEncode;
- (NSString *)zd_stringByURLDecode;

// MARK: Base64
- (nullable NSString *)zd_base64Encode;
- (nullable NSString *)zd_base64Decode;

// MARK: Get all parameters in url
- (nullable NSDictionary<NSString *, NSString *> *)zd_parameters;

@end

NS_ASSUME_NONNULL_END
