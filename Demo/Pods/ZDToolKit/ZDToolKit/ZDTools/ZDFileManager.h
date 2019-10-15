//
//  ZDFileManager.h
//  ZDUtility
//
//  Created by Zero on 15/7/11.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//  http://nshipster.cn/nsfilemanager/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDFileManager : NSObject

//MARK:Path
+ (NSString *)documentsPath;

+ (NSString *)libraryPath;

+ (NSString *)cachePath;

+ (NSString *)tempPath;

+ (NSString *)homePath;

+ (BOOL)isFileExistsAtPath:(NSString *)path;

+ (BOOL)isDirectoryAtPath:(NSString *)path;

//MARK:creat、move、remove、sizeCount
+ (BOOL)mkdirAtPath:(NSString *)path;

+ (BOOL)removeAtPath:(NSString *)path;

+ (BOOL)moveFromParh:(NSString *)fromPath
              toPath:(NSString *)toPath;

+ (BOOL)copyFromParh:(NSString *)fromPath
              toPath:(NSString *)toPath;

+ (long long)fileSizeAtPath:(NSString *)path;

+ (long long)folderSizeAtPath:(const char*)folderPath;

+ (unsigned long long)directorySize:(NSString *)directoryPath
                          recursive:(BOOL)recursive;

+ (long long)totalDiskSpace;

+ (long long)freeDiskSpace;

- (nullable NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path;

- (NSArray *)directoryContentsAtPath:(NSString *)path;

- (NSString *)currentDirectoryPath;

/// 清空NSUserDefaults中的全部数据
+ (void)clearUserDefaults;

@end


///==================================================================

@interface NSString (Path)

- (NSString *)fileName;

- (NSString *)fileFullName;

- (NSString *)jointString:(NSString *)string;

- (NSString *)jointPath:(NSString *)path;

- (NSString *)jointExtension:(NSString *)extension;

/** Creates a unique filename that can be used for one temporary file or folder.
 
 The returned string is different on every call. It is created by combining the result from temporaryPath with a unique UUID.
 
 @return The generated temporary path.
 */
+ (NSString *)pathForTemporaryFile;

/** Appends or Increments a sequence number in brackets
 
 If the receiver already has a number suffix then it is incremented. If not then (1) is added.
 
 @return The incremented path
 */
- (NSString *)pathByIncrementingSequenceNumber;

/** Removes a sequence number in brackets
 
 If the receiver number suffix then it is removed. If not the receiver is returned.
 
 @return The modified path
 */
- (NSString *)pathByDeletingSequenceNumber;

@end

NS_ASSUME_NONNULL_END






















