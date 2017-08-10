//
//  MediaDataRequestTask.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "MediaDataRequestTask.h"
#import <Foundation/Foundation.h>
#import "LCFileHandle.h"
#import "LoaderCategory.h"

@interface MediaDataRequestTask() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;              //会话对象
@property (nonatomic, strong) NSURLSessionDataTask *task;         //任务

@end

@implementation MediaDataRequestTask
@synthesize fileName = _fileName;
@synthesize requestURL = _requestURL;
@synthesize cancel = _cancel;
@synthesize fileTotalLength = _fileTotalLength;
@synthesize contentLength = _contentLength;
@synthesize mimeType = _mimeType;
@synthesize cacheLength = _cacheLength;
@synthesize subscript = _subscript;
@synthesize requestOffset = _requestOffset;

- (void)dealloc {
    self.delegate = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //删除临时文件夹
//            [LCFileHandle clearCache];
        });
    }
    return self;
}

//判断能不能继续下载
- (BOOL)canCreateNewTempFile {
    if([LCFileHandle tempFileExistsWithIndex:_subscript]){
        //判断临时文件是不是从该切片的开始下载的
        NSDictionary *info = (NSDictionary *)[taskInfoList objectAtIndex:_subscript];
        BOOL isBegin = info[@"isBegin"];

        if (isBegin) {
            //文件存在比对是不是在下载的缓冲区 区间内
            NSUInteger filelength = [LCFileHandle tempFileLengthWithIndex:_subscript];
            _cacheLength = filelength;
            
            NSUInteger startOffset = (Grain_Size+1) * _subscript;
            NSUInteger endOffset = startOffset + filelength;
            
            BOOL seekEnable = (self.requestOffset>=startOffset && self.requestOffset <= endOffset);
            [self modifyListObjectAtIndex:seekEnable];
            return !seekEnable;
        }else{
            [self modifyListObjectAtIndex:[self isBeginCacheNode]];
            return YES;
        }
        
    }else{
        [self modifyListObjectAtIndex:[self isBeginCacheNode]];
        return YES;
    }
}

- (void)modifyListObjectAtIndex:(BOOL)isBegin {
    if(taskInfoList.count > 0 && _subscript < (taskInfoList.count-1)){
        [taskInfoList replaceObjectAtIndex:_subscript withObject:@{@"isBegin":[NSNumber numberWithBool:isBegin]}];
    }else{
        [taskInfoList addObject:@{@"isBegin":[NSNumber numberWithBool:isBegin]}];
    }
}

- (void)setRequestOffset:(NSUInteger)requestOffset {
    _requestOffset = requestOffset;
    
    _subscript = ceil(requestOffset/(Grain_Size+1));
    [self createTempCacheFile];
}

static NSMutableArray<NSDictionary *> *taskInfoList = nil;
- (void)createTempCacheFile {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskInfoList = [NSMutableArray<NSDictionary *> array];
    });
    
    if([self canCreateNewTempFile]){
        //创建临时文件
        [LCFileHandle createTempFile:_subscript];
    }
}
+ (void)setFileTotalLengthZero {
    fileTotalLength = 0;
    
}

- (void)setFileLength {
    NSInteger length = fileTotalLength - (self.requestOffset + self.cacheLength) - 1;
    _contentLength = MIN(length, Grain_Size) + 1;
}

- (NSUInteger)rangLength {
    NSInteger length = fileTotalLength - (self.requestOffset + self.cacheLength) - 1;
    
    NSInteger fileLen = MIN(length, Grain_Size) + 1;
    
    NSInteger ranglen = self.requestOffset+self.cacheLength+fileLen-1;
    return ranglen >= 0 ? ranglen : 0;
}

- (void)start {
    if([self rangLength] == 0 && fileTotalLength != 0){
        //该切片是否已经全部下载完成,是就通知加载下一个切片
        if(self.delegate && [self.delegate respondsToSelector:@selector(requestTaskFinishedWithIndex:)]){
            [self.delegate requestTaskFinishedWithIndex:_subscript];
        }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    //默认的是gzip ，但是压缩文件系统无法知道文件的大小，所以给返回-1;
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    NSLog(@"bytes=%lu-%ld=========",self.requestOffset+self.cacheLength, [self rangLength]);
    if(self.requestOffset > 0){
        [request addValue:[NSString stringWithFormat:@"bytes=%lu-%ld", self.requestOffset+self.cacheLength, [self rangLength]] forHTTPHeaderField:@"Range"];
    }
        
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (BOOL)isBeginCacheNode {
    if (self.requestOffset == (Grain_Size+1) * _subscript) {
        return YES;
    }
    
    return NO;
}

- (void)setCancel:(BOOL)cancel {
    _cancel = cancel;
    [self.task cancel];
    [self.session invalidateAndCancel];
}

+ (NSUInteger)getFileTotalLength
{
    return fileTotalLength;
}

static NSUInteger fileTotalLength=0;
#pragma -mark NSURLSessionDataDelegate
//服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if (self.cancel) return;
    NSLog(@"response: %@",response);
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSLog(@"contentRange ===== %@",contentRange);
        //    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
        //    _fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    
    fileTotalLength = httpResponse.expectedContentLength;
    [self setFileLength];
    
    completionHandler(NSURLSessionResponseAllow);
    
    _mimeType = MimeType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (self.cancel) return;
    
    [LCFileHandle writeTempFileData:data withIndex:_subscript];
    _cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache:)]) {
        float Progress = (_cacheLength + self.requestOffset) * 100 / fileTotalLength;
        [self.delegate requestTaskDidUpdateCache:Progress];
    }
    
    //第一个分片下载的长度大于下载粒度，停止下载
    if(self.requestOffset == 0 && self.cacheLength > Grain_Size){
        self.cancel = YES;
        [self cacheFinished];
    }
}

//判断是否可以保存缓存文件
- (void)cacheFinished {
    if(self.requestOffset + self.cacheLength >= fileTotalLength){
        NSString *filename = [NSString fileNameWithURL:self.requestURL];
        [LCFileHandle createTempFileWithName:filename];
        //已经加载到最后一个分片，查看是否可以保存
        for(int index=0; index <= _subscript; index++){
            if(![LCFileHandle tempFileExistsWithIndex:index]){
                [LCFileHandle clearCacheWithName:filename];
                if(self.delegate && [self.delegate respondsToSelector:@selector(requestTaskAllFinished: isComplete:)]){
                    [self.delegate requestTaskAllFinished:nil isComplete:NO];
                }
                return;
            }
            
            if(index==0){
                NSUInteger firstlength = [LCFileHandle tempFileLengthWithIndex:0];
                
                if(firstlength > Grain_Size){
                    [LCFileHandle copyFileDataToFile:[NSString getTempFilePath:filename] startOffset:0 length:Grain_Size sourcePath:[NSString tempFilePath:index]];
                }else{
                    [LCFileHandle copyFileDataToFile:[NSString getTempFilePath:filename] startOffset:0 sourcePath:[NSString tempFilePath:index]];
                }
            }else{
                [LCFileHandle copyFileDataToFile:[NSString getTempFilePath:filename] startOffset:0 sourcePath:[NSString tempFilePath:index]];
            }
        }
        
        //整个文件已经拼接完成，移动并删除临时文件，改为本地播放
        NSString *cachePath = [LCFileHandle cacheTempFileWithFileName:filename];
        [LCFileHandle clearCacheWithName:filename];
        
        [taskInfoList removeAllObjects];
        if(self.delegate && [self.delegate respondsToSelector:@selector(requestTaskAllFinished: isComplete:)]){
            NSURL *url = [NSURL fileURLWithPath:cachePath];
            [self.delegate requestTaskAllFinished:url isComplete:YES];
        }
    }else{
        //自动开启下一切片的下载
        if(self.delegate && [self.delegate respondsToSelector:@selector(requestTaskFinishedWithIndex:)]){
            [self.delegate requestTaskFinishedWithIndex:_subscript];
        }
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else {
            [self cacheFinished];
        }
    }
}
@end
