//
//  VideoAssetUrlLoader.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "VideoAssetUrlLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DataRequestTask.h"
#import "VideoDataRequestTask.h"
#import "NoCacheVideoDataRequestTask.h"
#import "LCFileHandle.h"

@interface VideoAssetUrlLoader() <RequestTaskDelegate> {
    NSUInteger _requestTotalLength;
    NSString *_moviename;
    NSString *_mimeType;
    AVAssetResourceLoadingRequest *_curLoadRequest;
    NSUInteger _requireRate;
    NSUInteger _requireFPS;
}
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, strong) DataRequestTask *requestTask;

@end

@implementation VideoAssetUrlLoader

- (BOOL)canMove:(CGFloat)Progress {
    BOOL flag = NO;
    @synchronized(self) {
        NSUInteger canReadLength = self.requestTask.requestOffset + self.requestTask.cacheLength;
        NSUInteger currenLen = _requestTotalLength * Progress;
        flag = ((canReadLength-_requireRate) >= currenLen);
    }
    return flag;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pendingRequests = [[NSMutableArray alloc] init];
        _type = AssetUrlCacheLoader;
    }
    return self;
}

- (NSURL *)getSchemeVideoURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (void)setType:(AssetUrlLoaderType)type {
    _type = type;
}

/**
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求， 需要为每一次请求作出处理
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 *
 */

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
//    NSSLog(@"WaitingLoadingRequest < requestedOffset  = %lld<  requestedLength = %ld", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.requestedLength);
    //如果加载完成直接读文件
    if(self.type == AssetUrlLocationLoader){
        [self fillData:loadingRequest];
        return YES;
    }
    _curLoadRequest = loadingRequest;
    [self addLoadingRequest:loadingRequest];
    
    
    return YES;
}

- (void)fillData:(AVAssetResourceLoadingRequest *)loadingRequest{
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(_mimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = _requestTotalLength;
    //请求还没有返回
    if(_requestTotalLength == 0){
        return ;
    }
    
    //读文件，填充数据
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = _requireRate;

    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    NSData *data = [LCFileHandle readTempFileDataWithOffset:requestedOffset length:respondLength tempName:_moviename];
    [loadingRequest.dataRequest respondWithData:data];
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
//    NSSLog(@"移除。。。。。。。。。。");
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - 处理LoadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.pendingRequests addObject:loadingRequest];
    
    @synchronized(self) {
        if (self.requestTask) {
            if(self.type == AssetUrlLiveLoader && loadingRequest.dataRequest.requestedOffset == 0 && loadingRequest.dataRequest.requestedLength != 2){
                [self newTaskWithLoadingRequest:loadingRequest];
                [self processRequestList];
                return;
            }
            
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset &&
                loadingRequest.dataRequest.requestedOffset < self.requestTask.requestOffset + self.requestTask.cacheLength) {
//                数据已经缓存，则直接完成
                NSSLog(@"数据已经缓存，则直接完成");
                [self processRequestList];
            }else {
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if(self.type == AssetUrlLiveLoader && self.seekRequire){
                    self.seekRequire = NO;
                    [self newTaskWithLoadingRequest:loadingRequest];
                    [self processRequestList];
                }
            }
        }else {
            [self newTaskWithLoadingRequest:loadingRequest];
        }
    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (self.requestTask) {
        self.requestTask.cancel = YES;
    }
    
    DataRequestTask *task = nil;
    switch (self.type) {
        case AssetUrlLiveLoader:
        {
            task = [[NoCacheVideoDataRequestTask alloc] init];
        }
            break;
        case AssetUrlCacheLoader:
        {
            task = [[VideoDataRequestTask alloc] init];
        }
            break;
            
        default:
            break;
    }
    
    task.requestURL = loadingRequest.request.URL;
    task.requestOffset = loadingRequest.dataRequest.requestedOffset;
    task.requestedLength = loadingRequest.dataRequest.requestedLength;
    task.fileTotalLength = _requestTotalLength;
    task.requireFPS = self.requestTask.requireFPS;
    task.requireRate = self.requestTask.requireRate;
    task.delegate = self;
    [task start];
    self.requestTask = task;
}

- (void)processRequestList {
    if(_requestTotalLength == 0){
        _requestTotalLength = self.requestTask.fileTotalLength;
        _moviename = self.requestTask.fileName;
        _mimeType = self.requestTask.mimeType;
        _requireRate = self.requestTask.requireRate;
        _requireFPS = self.requestTask.requireFPS;
    }
    
    NSMutableArray * finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.pendingRequests) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.pendingRequests removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
//    填写 contentInformationRequest的信息，注意contentLength需要填写下载的文件的总长度，contentType需要转换
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(_mimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = _requestTotalLength;
    //请求还没有返回
    if(_requestTotalLength == 0){
        return NO;
    }
    
    //读文件，填充数据
    NSUInteger cacheLength = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    
    if(requestedOffset < self.requestTask.requestOffset){
        return NO;
    }
    
    NSInteger canReadLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    
    if(canReadLength <= 0){
        return NO;
    }
    
    NSInteger readyLen = MIN(canReadLength, _requireRate/2);

    NSUInteger respondLength = MIN(readyLen, loadingRequest.dataRequest.requestedLength);
    
    NSSLog(@"cacheLength\t%ld\n, requestedOffset\t%lld\n, currentOffset \t%lu\n, self.requestTask.requestOffset  \t %ld\n canReadLength \t%ld\n, requestedLength \t%ld\n   readyLen \t %ld\n     _requireRate  \t %ld\n", cacheLength, loadingRequest.dataRequest.requestedOffset, (unsigned long)requestedOffset,self.requestTask.requestOffset,canReadLength, loadingRequest.dataRequest.requestedLength, readyLen, _requireRate);
    
    NSData *data = nil;
    if(self.type == AssetUrlCacheLoader){
        data = [LCFileHandle readTempFileDataWithOffset:requestedOffset length:respondLength tempName:_moviename];
    }else if(self.type == AssetUrlLiveLoader){
        data = [LCFileHandle readTempFileDataWithOffset:requestedOffset - self.requestTask.requestOffset length:respondLength tempName:_moviename];
    }
    
    [loadingRequest.dataRequest respondWithData:data];

    //如果完全响应了所需要的数据，则完成
    NSUInteger nowendOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    if (nowendOffset >= reqEndOffset) {
        [loadingRequest finishLoading];
        return YES;
    }
    return NO;
}

#pragma -mark  RequestTaskDelegate
- (void)requestTaskDidRecivedData {
    [self processRequestList];
}

- (void)requestTaskDidUpdateCache:(CGFloat)Progress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheProgress:)]) {
        [self.delegate cacheProgress:Progress];
    }
}

- (void)requestTaskDidFailWithError:(NSError *)error {
    //加载数据错误的处理
//    NSSLog(@"加载数据错误............");
    [self processRequestList];
}

- (void)noCacheRequestTaskDidRecivedData:(NSData *)data
{

}

- (void)requestTaskDidReceiveResponse
{
}

- (void)requestTaskFinishedWithUrl:(NSURL *)url
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(finishedCache:)]){
        [self.delegate finishedCache:url];
    }
}

- (void)requestTaskFinishedWithIndex:(NSUInteger)index
{
}

- (void)requestTaskAllFinished:(NSURL *)url isComplete:(BOOL)complete
{
}
@end
