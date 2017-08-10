//
//  X264Manager.h
//  FFmpeg_X264_Codec
//
//  Created by sunminmin on 15/9/7.
//  Copyright (c) 2015年 suntongmian@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

#ifdef __cplusplus
extern "C" {
#endif
    
#include "libavcodec/avcodec.h"
    
#ifdef __cplusplus
};
#endif


@protocol H264EncoderDelegate <NSObject>
    
@end

@interface X264Manager : NSObject

- (void)stopEncode;
- (BOOL)canEncode;
+ (instancetype)defaultManager;
- (void)startEncoder:(int)width height:(int)height;
/*
 * 将CMSampleBufferRef格式的数据编码成h264并写入文件
 */
- (void)encoderToH264:(CMSampleBufferRef)sampleBuffer compeleteBlock:(void (^)(NSString *, long tag,NSTimeInterval durate))complete;
/*
 * 释放资源
 */
- (void)freeX264Resource;


@end
