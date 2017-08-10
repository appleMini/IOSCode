//
//  LCFileHandle.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "LCFileHandle.h"
#import "LoaderCategory.h"

@interface LCFileHandle ()
@end

@implementation LCFileHandle
+ (BOOL)createTempFile {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (BOOL)createTempFileWithName:(NSString *)name {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [NSString getTempFilePath:name];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }

    NSString *dir = [NSString tempDirPath];
    BOOL isDir = nil;
    if([manager fileExistsAtPath:dir isDirectory:&isDir]){
        if(!isDir){
            [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }else{
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}
/**
 *  创建临时文件
 */
+ (BOOL)createTempFile:(NSUInteger)index {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [NSString tempFilePath:index];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (BOOL)tempFileExistsWithName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString getTempFilePath:name];
    
    return [manager fileExistsAtPath:path];
}

+ (BOOL)tempFileExistsWithIndex:(NSUInteger)index {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath:index];

    return [manager fileExistsAtPath:path];
}

+ (NSUInteger)tempFileLengthWithName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString getTempFilePath:name];
    
    if([manager fileExistsAtPath:path]){
        NSDictionary *attr = [manager attributesOfItemAtPath:path error:nil];
        return [attr[NSFileSize] integerValue];
    }
    
    return 0;
}

+ (NSUInteger)tempFileLengthWithIndex:(NSUInteger)index {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath:index];
    
    if([manager fileExistsAtPath:path]){
        NSDictionary *attr = [manager attributesOfItemAtPath:path error:nil];
        return [attr[NSFileSize] integerValue];
    }
    
    return 0;
}

+ (void)copyFileDataToFile:(NSString *)topath startOffset:(NSUInteger)offset sourcePath:(NSString *)srcpath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:topath] && [manager fileExistsAtPath:srcpath]){
        NSData *data = [NSData dataWithContentsOfFile:srcpath];
        if(data){
            NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:topath];
            [handle seekToEndOfFile];
            [handle writeData:[data subdataWithRange:NSMakeRange(offset, data.length)]];
            [handle closeFile];
        }
    }
}

+ (void)copyFileDataToFile:(NSString *)topath startOffset:(NSUInteger)offset  length:(NSUInteger)len sourcePath:(NSString *)srcpath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:topath] && [manager fileExistsAtPath:srcpath]){
        NSData *data = [NSData dataWithContentsOfFile:srcpath];
        if(data){
            NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:topath];
            [handle seekToEndOfFile];
            [handle writeData:[data subdataWithRange:NSMakeRange(offset, offset+len)]];
            [handle closeFile];
        }
    }
}

/**
 *  往临时文件写入数据
 */
+ (void)writeTempFileData:(NSData *)data withIndex:(NSUInteger)index
{
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath:index]];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
}

/**
 *  往临时文件写入数据
 */
+ (void)writeTempFileData:(NSData *)data withName:(NSString *)name
{
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[NSString getTempFilePath:name]];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
}

/**
 *  往临时文件写入数据
 */
+ (void)writeAppendTempFile:(NSUInteger)offset WithData:(NSData *)data withName:(NSString *)name
{
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[NSString getTempFilePath:name]];
    [handle seekToFileOffset:offset];
    [handle writeData:data];
    [handle closeFile];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length tempName:(NSString *)name
{
    NSUInteger len = [self tempFileLengthWithName:name];
    if(len < offset){
        return nil;
    }
    
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[NSString getTempFilePath:name]];
    [handle seekToFileOffset:offset];
    NSData *data = [handle readDataOfLength:MIN((len-offset), length)];
    [handle closeFile];
    return data;
}

/**
 *  读取临时文件数据
 */
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length tempIndex:(NSUInteger)index
{
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath:index]];
    [handle seekToFileOffset:offset];
    NSData *data = [handle readDataOfLength:length];
    [handle closeFile];
    return data;
}

/**
 *  保存临时文件到缓存文件夹
 */
+ (NSString *)cacheTempFileWithFileName:(NSString *)name
{
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString getTempFilePath:name] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
    
    return cacheFilePath;
}

/**
 *  是否存在缓存文件 存在：返回文件路径 不存在：返回nil
 */
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url
{
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

/**
 *  清空缓存文件
 */
+ (BOOL)clearCacheWithIndex:(NSUInteger)index
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath:index];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return YES;
}

+ (BOOL)clearCacheWithName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString getTempFilePath:name];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return YES;
}

+ (BOOL)clearCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempDirPath];
    BOOL isDirectory = YES;
    if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if(isDirectory){
            [manager removeItemAtPath:path error:nil];
        }
    }
    
    NSError *error = nil;
    [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        return NO;
    }
    return YES;
}

+ (BOOL)clearDocumentCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString cacheFolderPath];
    BOOL isDirectory = YES;
    if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if(isDirectory){
            [manager removeItemAtPath:path error:nil];
        }
    }
    
    NSError *error = nil;
    [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        return NO;
    }
    return YES;
}
@end
