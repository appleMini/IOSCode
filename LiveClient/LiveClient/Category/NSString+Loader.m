//
//  NSString+Loader.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "NSString+Loader.h"

@implementation NSString(Loader)
+ (NSString *)tempFilePath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"];
}

+ (NSString *)tempDirPath {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MediaCache"];
    return path;
}

+ (NSString *)getTempFilePath:(NSString *)name {
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MediaCache"] stringByAppendingPathComponent:name];
    return path;
}

+ (NSString *)tempFilePath:(NSInteger)index {
    NSString *path = [[[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MediaCache"] stringByAppendingPathComponent:[NSString stringWithFormat:@"temp%ld",index]];
    
    return path;
}

+ (NSString *)cacheFolderPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:@"MediaCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    NSString *unquery = [[url.path componentsSeparatedByString:@"?"] firstObject];
    return [[unquery componentsSeparatedByString:@"/"] lastObject];
}

@end
