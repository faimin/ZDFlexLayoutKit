//
//  ZDPermissionManager.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/31.
//
//

#import "ZDPermissionHandler.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

@implementation ZDPermissionHandler

/// 相机权限
+ (BOOL)zd_isCapturePermissionGranted {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        return NO;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block BOOL isGranted = YES;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            isGranted = granted;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return isGranted;
    }
    else {
        return YES;
    }
}

/// 相册权限
+ (BOOL)zd_isAssetsLibraryPermissionGranted {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
            return NO;
        }
        else if (authStatus == ALAuthorizationStatusNotDetermined) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL isGranted = YES;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusRestricted:
                    case PHAuthorizationStatusDenied:
                        isGranted = NO;
                        break;
                    case PHAuthorizationStatusAuthorized:
                        isGranted = YES;
                        break;
                    default:
                        break;
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            return isGranted;
        }
    }
    else {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
            return NO;
        }
        else if (authStatus == ALAuthorizationStatusNotDetermined) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL isGranted = YES;
            [[[ALAssetsLibrary alloc] init] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                isGranted = YES;
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
            } failureBlock:^(NSError *error) {
                isGranted = NO;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            return isGranted;
        }
    }
    
    return YES;
}

@end







