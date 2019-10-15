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
                  extraConfig:(void(NS_NOESCAPE ^)(UIAlertController *alertController))configBlock
              completePresent:(void(^)(void))completion
               clickedHandler:(void(^)(UIAlertAction *action, NSInteger tag))handler
                      actions:(ZDActionModel *)actionModel, ... NS_REQUIRES_NIL_TERMINATION {
    
    if (!actionModel) return;
    
    if (!controller) {
        // https://www.appcoda.com.tw/uialertcontroller
        controller = [[UIViewController alloc] init];
        UIWindow *alertWindow = ({
            UIWindow *view = [[UIWindow alloc] init];
            view.backgroundColor = UIColor.clearColor;
            view.windowLevel = UIWindowLevelAlert;
            view.hidden = NO;
            view;
        });
        alertWindow.rootViewController = controller;
    }
    
    va_list params;
    va_start(params, actionModel);
    UIAlertController *alertController = [self setupAlertControllerWithTitle:title message:message preferredStyle:preferredStyle actionModel:actionModel actionModels:params clickedHandler:handler];
    va_end(params);
    
    if (configBlock) configBlock(alertController);
    
    [controller presentViewController:alertController animated:YES completion:completion];
}

+ (UIAlertController *)setupAlertControllerWithTitle:(NSString *)title
                                             message:(NSString *)message
                                      preferredStyle:(UIAlertControllerStyle)preferredStyle
                                         actionModel:(ZDActionModel *)actionModel
                                        actionModels:(va_list)actionModels
                                      clickedHandler:(void(^)(UIAlertAction *action, NSInteger tag))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    ZDActionModel *tempModel = actionModel;
    do {
        UIAlertAction *zdAction = [UIAlertAction actionWithTitle:tempModel.title style:tempModel.style handler:^(UIAlertAction * _Nonnull action) {
            NSInteger actionTag = [objc_getAssociatedObject(action, ZD_UIAlertAction_Key) integerValue];
            if (handler) handler(action, actionTag);
        }];
        objc_setAssociatedObject(zdAction, ZD_UIAlertAction_Key, @(tempModel.tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [alertController addAction:zdAction];
    } while ((tempModel = va_arg(actionModels, ZDActionModel *)));
    
    return alertController;
}

@end

@implementation ZDActionModel
@end
