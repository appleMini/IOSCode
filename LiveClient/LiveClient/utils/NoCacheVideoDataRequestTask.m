//
//  VideoDataRequestTask.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "NoCacheVideoDataRequestTask.h"
#import <Foundation/Foundation.h>
#import "LoaderCategory.h"
#import "LCFileHandle.h"

@interface NoCacheVideoDataRequestTask() <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;              //会话对象
@property (nonatomic, strong) NSURLSessionDataTask *task;         //任务

@end

@implementation NoCacheVideoDataRequestTask
@synthesize fileName = _fileName;
@synthesize requestURL = _requestURL;
@synthesize cancel = _cancel;
@synthesize fileTotalLength = _fileTotalLength;
@synthesize contentLength = _contentLength;
@synthesize mimeType = _mimeType;
@synthesize cacheLength = _cacheLength;
@synthesize requireRate = _requireRate;
@synthesize requireFPS = _requireFPS;

- (void)dealloc {
    self.delegate = nil;
}

- (void)setRequestURL:(NSURL *)requestURL {
    // 替代NSMutableURL, 可以动态修改scheme
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:requestURL resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";
    _requestURL = [actualURLComponents URL];
    //    创建临时文件
    _fileName = [NSString fileNameWithURL:_requestURL];
    [LCFileHandle createTempFileWithName:_fileName];
}


- (void)start {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    //默认的是gzip ，但是压缩文件系统无法知道文件的大小，所以给返回-1;
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    if(self.fileTotalLength == 0){
        [request addValue:@"bytes=0-1" forHTTPHeaderField:@"Range"];
    }else{
        
        NSSLog(@"====self.requestOffset==  =%ld,  ==self.requestOffset + (self.requireFPS*self.requireRate)-1==%ld",self.requestOffset, (self.requireFPS*self.requireRate)-1);
        [request addValue:[NSString stringWithFormat:@"bytes=%lu-%ld", self.requestOffset, self.requestOffset + (self.requireRate*self.requireFPS)-1] forHTTPHeaderField:@"Range"];
    }
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    [self.task cancel];
    [self.session invalidateAndCancel];
}

- (NSUInteger)parseFileLength:(NSString *)ContentRange {
    NSRange range = [ContentRange rangeOfString:@"/"];
    NSString *length = [ContentRange substringFromIndex:(range.location+1)];
    return length.integerValue;
}

#pragma -mark NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if (self.cancel) return;
    NSSLog(@"response: %@",response);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *cLength = [[httpResponse allHeaderFields] objectForKey:@"Content-Length"];
    //        NSSLog(@"cLength ===== %@",cLength);
    NSString *ContentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    
    if(self.fileTotalLength == 0){
        NSString *FPS = [[httpResponse allHeaderFields] objectForKey:@"MovieInfo-FPS"];
        //        NSSLog(@"FPS ===== %@",FPS);
        int fps = DEFAULT_FPS;
        if (FPS) {
            fps = FPS.intValue;
        }
        NSString *RATE = [[httpResponse allHeaderFields] objectForKey:@"MovieInfo-RATE"];
        //        NSSLog(@"RATE ===== %@",RATE);
        int rate = DEFAULT_RATE; //2M 默认
        if (RATE) {
            rate = RATE.intValue;
        }
        
        _requireFPS = fps;
        _requireRate = rate;
        _mimeType = MimeType;
        
        _fileTotalLength = ContentRange ? [self parseFileLength:ContentRange] : httpResponse.expectedContentLength;
        
        VideoModel *model = [VideoModel sharedVideoModel];
        model.fileLength = self.fileTotalLength;
        model.rate = self.requireRate;
        model.fps = self.requireFPS;
        model.mimeType = self.mimeType;
    }
    
    _contentLength = cLength ? cLength.integerValue : httpResponse.expectedContentLength;
    
    completionHandler(NSURLSessionResponseAllow);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (self.cancel) return;
    
    [LCFileHandle writeAppendTempFile:self.cacheLength WithData:data withName:self.fileName];
    _cacheLength += data.length;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidRecivedData)]){
        [self.delegate requestTaskDidRecivedData];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache:)]) {
                float Progress = (_cacheLength + self.requestOffset) * 100 / self.fileTotalLength;
                [self.delegate requestTaskDidUpdateCache:Progress];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }
    }
}
@end
