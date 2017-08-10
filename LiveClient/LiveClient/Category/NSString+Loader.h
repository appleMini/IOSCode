//
//  NSString+Loader.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Loader)
+ (NSString *)tempFilePath;
+ (NSString *)tempDirPath;

+ (NSString *)getTempFilePath:(NSString *)name;
/**
 *  临时文件路径
 */
+ (NSString *)tempFilePath:(NSInteger)index;

/**
 *  缓存文件夹路径
 */
+ (NSString *)cacheFolderPath;

/**
 *  获取网址中的文件名
 */
+ (NSString *)fileNameWithURL:(NSURL *)url;

@end
