//
//  ZDFileManager.m
//  ZDUtility
//
//  Created by Zero on 15/7/11.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "ZDFileManager.h"
#import <dirent.h>
#import <sys/mount.h>
#import <sys/stat.h>
//
//#import <sys/types.h>
//#import <sys/param.h>
//#import <unistd.h>
//#import <fcntl.h>
//#import <pwd.h>
//#import <grp.h>
//#import <dirent.h>
//#import <errno.h>

@implementation ZDFileManager

+ (NSString *)documentsPath {
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

	return (documentsPath ? : @"");
}

+ (NSString *)libraryPath {
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];

	return (libraryPath ? : @"");
}

+ (NSString *)cachePath {
	NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

	return (cachePath ? : @"");
}

+ (NSString *)tempPath {
	return NSTemporaryDirectory();
}

+ (NSString *)homePath {
	return NSHomeDirectory();
}

+ (BOOL)isFileExistsAtPath:(NSString *)path {
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isDirectoryAtPath:(NSString *)path {
	BOOL isDirectory;
	NSFileManager *fileManager = [[NSFileManager alloc] init];

	[fileManager fileExistsAtPath:path isDirectory:&isDirectory];
	return isDirectory;
}

//MARK:
+ (BOOL)mkdirAtPath:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];

	if (!(isDir && existed)) {
		NSError *__autoreleasing error;
		BOOL isOK = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];

		if (error) {
			NSLog(@"创建文件夹失败：%@", error);
		}
		return isOK;
	}
	NSLog(@"文件夹已存在at路径：%@", path);
	return NO;
}

+ (BOOL)removeAtPath:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:path]) {
		NSLog(@"移除失败：文件不存在");
		return NO;
	}
	NSError *__autoreleasing error;
	BOOL isOK = [fileManager removeItemAtPath:path error:&error];

	if (error) {
		NSLog(@"移除失败：%@", error);
	}
	return isOK;
}

+ (BOOL)moveFromParh:(NSString *)fromPath toPath:(NSString *)toPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:fromPath]) {
		NSLog(@"移动失败：文件不存在");
		return NO;
	}
	NSError *__autoreleasing error;
	BOOL isOK = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];

	if (error) {
		NSLog(@"移动失败：%@", error);
	}
	return isOK;
}

+ (BOOL)copyFromParh:(NSString *)fromPath toPath:(NSString *)toPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:fromPath]) {
		NSLog(@"复制失败：文件不存在");
		return NO;
	}
	NSError *__autoreleasing error;
	BOOL isOK = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];

	if (error) {
		NSLog(@"复制失败：%@", error);
	}
	return isOK;
}

+ (long long)fileSizeAtPath:(NSString *)path {
	NSError *__autoreleasing error;
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];

	return [attributes fileSize];
}

+ (long long)folderSizeAtPath:(const char *)folderPath {
	long long folderSize = 0;
	DIR *dir = opendir(folderPath);

	if (dir == NULL) {
		return 0;
	}
	struct dirent *child;

	while ( (child = readdir(dir) ) != NULL) {
		if ( (child->d_type == DT_DIR) && (
				( (child->d_name[0] == '.') && (child->d_name[1] == 0) ) ||
				( (child->d_name[0] == '.') && (child->d_name[1] == '.') && (child->d_name[2] == 0) )
				) ) {
			continue;
		}

		int folderPathLength = (int)strlen(folderPath);
		char childPath[1024];
		stpcpy(childPath, folderPath);

		if (folderPath[folderPathLength - 1] != '/') {
			childPath[folderPathLength] = '/';
			folderPathLength++;
		}
		stpcpy(childPath + folderPathLength, child->d_name);
		childPath[folderPathLength + child->d_namlen] = 0;

		if (child->d_type == DT_DIR) {
			folderSize += [self folderSizeAtPath:childPath];
			struct stat st;

			if (lstat(childPath, &st) == 0) {
				folderSize += st.st_size;
			}
		}
		else if ( (child->d_type == DT_REG) || (child->d_type == DT_LNK) ) {
			struct stat st;

			if (lstat(childPath, &st) == 0) {
				folderSize += st.st_size;
			}
		}
	}

	return folderSize;
}

+ (unsigned long long)directorySize:(NSString *)directoryPath recursive:(BOOL)recursive {
	unsigned long long size = 0;
	BOOL isDir = NO;

	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:directoryPath isDirectory:&isDir] && isDir) {
        NSError *__autoreleasing error;
		NSArray *contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
        if (error) NSLog(@"%@", error);

		for (NSString *item in contents) {
			NSString *fullItem = [directoryPath stringByAppendingPathComponent:item];

			if ([fileManager fileExistsAtPath:fullItem isDirectory:&isDir]) {
				if (isDir && recursive) {
					size += [[self class] directorySize:fullItem recursive:YES];
				}
				else {
					size += [[[fileManager attributesOfItemAtPath:fullItem error:nil] objectForKey:NSFileSize] unsignedLongLongValue];
				}
			}
		}
	}
	return size;
}

+ (long long)totalDiskSpace {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs tStats;

	//statfs([[paths lastObject] cString], &tStats);
    statfs([[paths lastObject] UTF8String], &tStats);
	long long totalSpace = (long long)(tStats.f_blocks * tStats.f_bsize);
	return totalSpace;
}

+ (long long)freeDiskSpace {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs buf;
	long long freespace = -1;
    
    //statfs([[paths lastObject] cString], &buf
	if (statfs([[paths lastObject] UTF8String], &buf) >= 0) {
		freespace = (long long)buf.f_bsize * buf.f_bfree;
	}
	return freespace;
}

// https://github.com/mpw/marcelweiher-libobjc2/blob/4612302061a3657bc95a387ddca8db58c6dd60c5/Foundation/platform_posix/NSFileManager_posix.m
- (NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path {
    char linkbuf[MAXPATHLEN + 1];
    size_t length;
    
    length = readlink([path fileSystemRepresentation], linkbuf, MAXPATHLEN);
    if (length == -1)
        return nil;
    
    linkbuf[length] = 0;
    return [NSString stringWithCString:linkbuf encoding:NSUTF8StringEncoding];
}

- (NSArray *)directoryContentsAtPath:(NSString *)path {
    NSMutableArray *result = nil;
    DIR *dirp = NULL;
    struct dirent *dire;
    
    if(path == nil) {
        return nil;
    }
    
    dirp = opendir([path fileSystemRepresentation]);
    
    if (dirp == NULL)
        return nil;
    
    result = [[NSMutableArray alloc] init];
    
    while ((dire = readdir(dirp))) {
        if (strcmp(".", dire->d_name) == 0)
            continue;
        if (strcmp("..", dire->d_name) == 0)
            continue;
        NSString *str = [NSString stringWithCString:dire->d_name encoding:NSUTF8StringEncoding];
        if (str) [result addObject:str];
    }
    
    closedir(dirp);
    
    return result;
}

- (NSString *)currentDirectoryPath {
    char path[MAXPATHLEN + 1];
    
    if (getcwd(path, sizeof(path)) != NULL)
        return [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
    
    return nil;
}
 
+ (void)clearUserDefaults {
#if 1
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#else
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefaults dictionaryRepresentation];
    for (id key in dict) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
#endif
}

@end

///===================================================================

@implementation NSString (Path)

- (NSString *)fileName {
	return [[self lastPathComponent] stringByDeletingLastPathComponent];
}

- (NSString *)fileFullName {
	return [self lastPathComponent];
}

- (NSString *)jointString:(NSString *)string {
	return [self stringByAppendingString:string];
}

- (NSString *)jointPath:(NSString *)path {
	return [self stringByAppendingPathComponent:path];
}

- (NSString *)jointExtension:(NSString *)extension {
	return [self stringByAppendingPathExtension:extension];
}

+ (NSString *)pathForTemporaryFile {
	CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString *)newUniqueIdString];

	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);

	return tmpPath;
}

- (NSString *)pathByIncrementingSequenceNumber {
	NSString *baseName = [self stringByDeletingPathExtension];
	NSString *extension = [self pathExtension];

	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(([0-9]+)\\)$" options:0 error:NULL];

    __block NSInteger sequenceNumber = 0;
	[regex enumerateMatchesInString:baseName options:0 range:NSMakeRange(0, [baseName length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
		NSRange range = [match rangeAtIndex:1]; // first capture group
		NSString *substring = [self substringWithRange:range];

		sequenceNumber = [substring integerValue];
		*stop = YES;
	}];

	NSString *nakedName = [baseName pathByDeletingSequenceNumber];

	if ([extension isEqualToString:@""]) {
		return [nakedName stringByAppendingFormat:@"(%d)", (int)sequenceNumber + 1];
	}

	return [[nakedName stringByAppendingFormat:@"(%d)", (int)sequenceNumber + 1] stringByAppendingPathExtension:extension];
}

- (NSString *)pathByDeletingSequenceNumber {
	NSString *baseName = [self stringByDeletingPathExtension];

	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\([0-9]+\\)$" options:0 error:NULL];
	__block NSRange range = NSMakeRange(NSNotFound, 0);

	[regex enumerateMatchesInString:baseName options:0 range:NSMakeRange(0, [baseName length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
		range = [match range];

		*stop = YES;
	}];

	if (range.location != NSNotFound) {
		return [self stringByReplacingCharactersInRange:range withString:@""];
	}

	return self;
}

@end
