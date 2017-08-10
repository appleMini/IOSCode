//
//  DataRequestTask.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/23.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoModel.h"

#define MimeType @"video/mp4"
#define RequestTimeout -1
#define DEFAULT_FPS 30 //默认帧率
#define DEFAULT_RATE 1024*1024*2 //默认码率，2M

@protocol RequestTaskDelegate;
@interface DataRequestTask : NSObject
@property (nonatomic, strong) NSURL * requestURL; //请求网址
@property (nonatomic, assign) NSUInteger requestedLength; //请求长度
@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
@property (nonatomic, assign, readonly) NSUInteger cacheLength; //缓冲长度
@property (nonatomic, assign, readonly) NSUInteger contentLength; //长度
@property (nonatomic, assign) NSUInteger requireRate; //视频播放的最小长度
@property (nonatomic, assign) NSUInteger requireFPS; //视频播放的最小长度
@property (nonatomic, assign) NSUInteger fileTotalLength; //文件总长度
@property (nonatomic, assign, readonly) NSUInteger subscript; //缓冲长度
@property (nonatomic, copy, readonly) NSString *fileName; //缓冲长度
@property (nonatomic, assign) BOOL cancel; //是否取消请求
@property (nonatomic, strong, readonly) NSString *mimeType;
@property (nonatomic, weak) id<RequestTaskDelegate> delegate;

/**
 *  开始请求
 */
- (void)start;
@end

@protocol RequestTaskDelegate <NSObject>
@required
- (void)requestTaskDidUpdateCache:(CGFloat)Progress; //更新缓冲进度代理方法
- (void)requestTaskDidRecivedData;   //接收到数据
- (void)noCacheRequestTaskDidRecivedData:(NSData *)data;   //接收到数据

@optional
- (void)requestTaskDidReceiveResponse;
- (void)requestTaskDidFailWithError:(NSError *)error;
- (void)requestTaskFinished;
- (void)requestTaskFinishedWithUrl:(NSURL *)url;
- (void)requestTaskFinishedWithIndex:(NSUInteger)index;
- (void)requestTaskAllFinished:(NSURL *)url isComplete:(BOOL)complete;
@end
