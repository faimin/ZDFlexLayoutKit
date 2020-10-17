//
//  ZDBlock.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import <Foundation/Foundation.h>

@interface ZDBlockDescription : NSObject

@end

FOUNDATION_EXPORT const char *ZD_BlockGetType(id block);
FOUNDATION_EXPORT BOOL ZD_BlockIsCompatibleWithMethodType(id block, const char *methodType);
