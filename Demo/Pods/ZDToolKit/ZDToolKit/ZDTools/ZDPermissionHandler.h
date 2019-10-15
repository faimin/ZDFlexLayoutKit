//
//  ZDPermissionManager.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/31.
//
//

#import <Foundation/Foundation.h>

@interface ZDPermissionHandler : NSObject

/// 相机权限
+ (BOOL)zd_isCapturePermissionGranted;

/// 相册权限
+ (BOOL)zd_isAssetsLibraryPermissionGranted;

@end
