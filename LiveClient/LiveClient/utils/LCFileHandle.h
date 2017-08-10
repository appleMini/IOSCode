//
//  LCFileHandle.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCFileHandle : NSObject
+ (BOOL)createTempFile;
/**
 *  创建临时文件
 */
+ (BOOL)createTempFileWithName:(NSString *)name;

/**
 *  往临时文件写入数据
 */
+ (void)copyFileDataToFile:(NSString *)topath startOffset:(NSUInteger)offset sourcePath:(NSString *)srcpath;

+ (void)copyFileDataToFile:(NSString *)topath startOffset:(NSUInteger)offset  length:(NSUInteger)len sourcePath:(NSString *)srcpath;
/**
 *  创建临时文件
 */
+ (BOOL)createTempFile:(NSUInteger)index;
+ (void)writeAppendTempFile:(NSUInteger)offset WithData:(NSData *)data withName:(NSString *)name;
+ (void)writeTempFileData:(NSData *)data withName:(NSString *)name;
/**
 *  往临时文件写入数据
 */
+ (void)writeTempFileData:(NSData *)data withIndex:(NSUInteger)index;

+ (BOOL)tempFileExistsWithName:(NSString *)name;
+ (BOOL)tempFileExistsWithIndex:(NSUInteger)index;

+ (NSUInteger)tempFileLengthWithName:(NSString *)name;
+ (NSUInteger)tempFileLengthWithIndex:(NSUInteger)index;
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length tempName:(NSString *)name;
/**
 *  读取临时文件数据
 */
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length tempIndex:(NSUInteger)index;

/**
 *  保存临时文件到缓存文件夹
 */
+ (NSString *)cacheTempFileWithFileName:(NSString *)name;

/**
 *  是否存在缓存文件 存在：返回文件路径 不存在：返回nil
 */
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url;

/**
 *  清空缓存文件
 */
+ (BOOL)clearCacheWithIndex:(NSUInteger)index;
+ (BOOL)clearCacheWithName:(NSString *)name;
+ (BOOL)clearCache;
+ (BOOL)clearDocumentCache;
@end
