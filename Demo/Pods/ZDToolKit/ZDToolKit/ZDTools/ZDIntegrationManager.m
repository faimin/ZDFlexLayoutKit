//
//  ZDIntegrationManager.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2018/5/29.
//

#import "ZDIntegrationManager.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

char *const ZDInjectableSectionName = "ZDInjectable";

static NSArray<Class> *ZD_ReadConfigurationClasses() {
    static NSMutableArray<Class> *classes;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Dl_info info;
        dladdr(ZD_ReadConfigurationClasses, &info);
        
#ifndef __LP64__
        const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
        unsigned long size = 0;
        uint32_t *memory = (uint32_t*)getsectiondata(mhp, SEG_DATA, ZDInjectableSectionName, &size);
#else /* defined(__LP64__) */
        const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
        unsigned long size = 0;
        uint64_t *memory = (uint64_t*)getsectiondata(mhp, SEG_DATA, ZDInjectableSectionName, &size);
#endif /* defined(__LP64__) */
        
        classes = [NSMutableArray new];
        
        for (int idx = 0; idx < size/sizeof(void*); ++idx){
            char *string = (char *)memory[idx];
            
            NSString *className = [NSString stringWithUTF8String:string];
            if (!className) continue;
            
            NSLog(@"class name = %@", className);
            Class cls = NSClassFromString(className);
            if (cls) [classes addObject:cls];
        }
    });
    
    return classes;
}


@implementation ZDIntegrationManager

+ (Class)zd_classForProtocol:(Protocol *)protocol {
    NSArray<Class> *classes = [self zd_classesForProtocol:protocol];
    Class result = classes.firstObject;
    return result;
}

+ (NSArray<Class> *)zd_classesForProtocol:(Protocol *)protocol {
    NSArray<Class> *allClasses = ZD_ReadConfigurationClasses();
    
    NSMutableArray<Class> *resultClasses = [NSMutableArray new];
    for (Class cls in allClasses) {
        if (class_conformsToProtocol(cls, protocol)) {
            [resultClasses addObject:cls];
        }
    }
    
    return resultClasses;
}

@end
