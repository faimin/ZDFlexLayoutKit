//
//  ZDAlertControllerHelper.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/12/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NEW_ACTION_MODEL(_title_, UIAlertActionStyleDefault, _tag_)         \
({                                                                          \
ZDActionModel *model = [ZDActionModel new];                                 \
model.title = _title_;                                                      \
model.style = UIAlertActionStyleDefault;                                    \
model.tag = _tag_;                                                          \
model;                                                                      \
})

NS_ASSUME_NONNULL_BEGIN

@class ZDActionModel;
NS_CLASS_AVAILABLE_IOS(8_0) @interface ZDAlertControllerHelper : NSObject

+ (void)showAlertControllerIn:(__kindof UIViewController *)controller
                        title:(nullable NSString *)title
                      message:(nullable NSString *)message
               preferredStyle:(UIAlertControllerStyle)preferredStyle
               clickedHandler:(void(^ _Nullable)(UIAlertAction *action, NSInteger tag))handler
                      actions:(ZDActionModel *)actionModel, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)showAlertControllerIn:(__kindof UIViewController *)controller
                        title:(nullable NSString *)title
                      message:(nullable NSString *)message
               preferredStyle:(UIAlertControllerStyle)preferredStyle
               clickedHandler:(void(^ _Nullable)(UIAlertAction *action, NSInteger tag))handler
                  extraConfig:(void(^ _Nullable)(UIAlertController *alertController))configBlock
              completePresent:(void(^ _Nullable)(void))completion
                      actions:(ZDActionModel *)actionModel, ... NS_REQUIRES_NIL_TERMINATION;

@end

//---------------------------------------------

@interface ZDActionModel : NSObject
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, assign) UIAlertActionStyle style;
@property (nonatomic, assign) NSInteger tag;
@end

NS_ASSUME_NONNULL_END
