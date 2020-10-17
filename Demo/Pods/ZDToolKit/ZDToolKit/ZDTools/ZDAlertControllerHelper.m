//
//  ZDAlertControllerHelper.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/12/26.
//

#import "ZDAlertControllerHelper.h"
#import <objc/runtime.h>

static const void *ZD_UIAlertAction_Key = &ZD_UIAlertAction_Key;

@implementation ZDAlertControllerHelper

+ (void)showAlertControllerIn:(__kindof UIViewController *)controller
                        title:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(UIAlertControllerStyle)preferredStyle
               clickedHandler:(void(^)(UIAlertAction *action, NSInteger tag))handler
                      actions:(ZDActionModel *)actionModel, ... NS_REQUIRES_NIL_TERMINATION {
    if (!controller) return;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (actionModel) {
        ZDActionModel *tempModel = actionModel;
        
        va_list params;
        va_start(params, actionModel);
        
        do {
            UIAlertAction *mdAction = [UIAlertAction actionWithTitle:tempModel.title style:tempModel.style handler:^(UIAlertAction * _Nonnull action) {
                NSInteger actionTag = [objc_getAssociatedObject(action, ZD_UIAlertAction_Key) integerValue];
                if (handler) handler(action, actionTag);
            }];
            objc_setAssociatedObject(mdAction, ZD_UIAlertAction_Key, @(tempModel.tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [alertController addAction:mdAction];
        } while ((tempModel = va_arg(params, ZDActionModel *)));
        
        va_end(params);
    }
    
    [controller presentViewController:alertController animated:YES completion:^{
        //
    }];
}

+ (void)showAlertControllerIn:(__kindof UIViewController *)controller
                        title:(NSString *)title
                      message:(NSString *)message
               preferredStyle:(UIAlertControllerStyle)preferredStyle
               clickedHandler:(void(^)(UIAlertAction *action, NSInteger tag))handler
                  extraConfig:(void(^)(UIAlertController *alertController))configBlock
              completePresent:(void(^)(void))completion
                      actions:(ZDActionModel *)actionModel, ... NS_REQUIRES_NIL_TERMINATION {
    if (!controller) return;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if (actionModel) {
        ZDActionModel *tempModel = actionModel;
        
        va_list params;
        va_start(params, actionModel);
        
        do {
            UIAlertAction *mdAction = [UIAlertAction actionWithTitle:tempModel.title style:tempModel.style handler:^(UIAlertAction * _Nonnull action) {
                NSInteger actionTag = [objc_getAssociatedObject(action, ZD_UIAlertAction_Key) integerValue];
                if (handler) handler(action, actionTag);
            }];
            objc_setAssociatedObject(mdAction, ZD_UIAlertAction_Key, @(tempModel.tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [alertController addAction:mdAction];
        } while ((tempModel = va_arg(params, ZDActionModel *)));
        
        va_end(params);
    }
    
    if (configBlock) configBlock(alertController);
    
    [controller presentViewController:alertController animated:YES completion:completion];
}

@end

@implementation ZDActionModel
@end
