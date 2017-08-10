//
//  AWGPUImageAVCaptureDataHandler.m
//  LiveClient
//
//  Created by 小布丁 on 2017/2/26.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "AWGPUImageAudioHandler.h"
@interface AWGPUImageAudioHandler ()

@end

@implementation AWGPUImageAudioHandler

- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer {
    
}

#pragma -mark
#pragma -mark
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex{
    NSLog(@"========================");
////将bgra转为yuv
////图像宽度
//int width = aw_stride((int)imageSize.width);
////图像高度
//int height = imageSize.height;
////宽*高
//int w_x_h = width * height;
////yuv数据长度 = (宽 * 高) * 3 / 2
//int yuv_len = w_x_h * 3 / 2;
//
////yuv数据
//uint8_t *yuv_bytes = malloc(yuv_len);
//
////ARGBToNV12这个函数是libyuv这个第三方库提供的一个将bgra图片转为yuv420格式的一个函数。
////libyuv是google提供的高性能的图片转码操作。支持大量关于图片的各种高效操作，是视频推流不可缺少的重要组件，你值得拥有。
//[self lockFramebufferForReading];
//ARGBToNV12(self.rawBytesForImage, width * 4, yuv_bytes, width, yuv_bytes + w_x_h, width, width, height);
//[self unlockFramebufferAfterReading];
//
//NSData *yuvData = [NSData dataWithBytesNoCopy:yuv_bytes length:yuv_len];
//
//[self.capture sendVideoYuvData:yuvData];
}
@end
