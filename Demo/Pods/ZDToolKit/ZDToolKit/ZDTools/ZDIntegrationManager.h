//
//  ZDIntegrationManager.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/29.
//

#import <Foundation/Foundation.h>

extern char *const ZDInjectableSectionName;
#define ZDInjectable __attribute__((used, section("__DATA, ZDInjectable")))

@interface ZDIntegrationManager : NSObject

+ (Class)zd_classForProtocol:(Protocol *)protocol;

+ (NSArray<Class> *)zd_classesForProtocol:(Protocol *)protocol;

@end
