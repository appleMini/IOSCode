//
//  H264SendHelper.m
//  LiveClient
//
//  Created by 小布丁 on 2017/2/27.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "H264SendHelper.h"
#import "RHSocketConnection.h"

@interface H264SendHelper() <RHSocketConnectionDelegate>{
    dispatch_queue_t _dataQueue;
}

@property (nonatomic, strong) RHSocketConnection *connect;

@end

@implementation H264SendHelper
static H264SendHelper *helper = nil;

- (void)dealloc
{
    _connect.delegate = nil;
    _connect = nil;
}

+ (id)defaultH264SendHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!helper) {
            helper = [[H264SendHelper alloc] init];
        }
    });
    
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataQueue = dispatch_queue_create("send data queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)sendPacketWithPath:(NSString *)path withACCPath:(NSString *)accpath withDuration:(NSTimeInterval)durate{
    __weak typeof(self) ws = self;
    dispatch_async(_dataQueue, ^{
        if(!path || !accpath){
            return ;
        }
        NSData *data264 = [NSData dataWithContentsOfFile:path options:0 error:NULL];
        NSData *acc = [NSData dataWithContentsOfFile:accpath options:0 error:NULL];
        
        NSString *header = nil;
        
        header = [NSString stringWithFormat:@"Header-Length:%ldACC:Start:",[acc length]];
        //发送 acc 音频数据
        [ws.connect writeData:[header dataUsingEncoding:NSUTF8StringEncoding] timeout:-1 tag:0];
        [ws.connect writeData:acc timeout:-1 tag:0];
        [ws deleteFileAfterSendOver:accpath];
        
        
        if (durate == 0) {
            header = [NSString stringWithFormat:@"Header-Length:%ldStart:",[data264 length]];
        }else{
            header = [NSString stringWithFormat:@"Header-Length:%ldDuration:%fStart:",[data264 length],durate];
        }
        
        [ws.connect writeData:[header dataUsingEncoding:NSUTF8StringEncoding] timeout:-1 tag:0];
        [ws.connect writeData:data264 timeout:-1 tag:0];
        [ws deleteFileAfterSendOver:path];
    });
}

- (void)sendPacket:(NSData *)data withTag:(long)tag{
    __weak typeof(self) ws = self;
    dispatch_async(_dataQueue, ^{
        NSString *header = [NSString stringWithFormat:@"Header-Length:%ldStart:",[data length]];
        [ws.connect writeData:[header dataUsingEncoding:NSUTF8StringEncoding] timeout:-1 tag:0];
        [ws.connect writeData:data timeout:20 tag:tag];
//        dispatch_suspend(_dataQueue);
    });
}

- (void)startConnect {
    NSString *serverHost = ServerSocketAddr;
    int serverPort = ServerPORT;
    _connect = [[RHSocketConnection alloc] init];
    [_connect connectWithHost:serverHost port:serverPort withDelegate:self];
}

- (void)disConnection {
    [self.connect disconnect];
}

#pragma -mark  RHSocketConnectionDelegate
- (void)didDisconnectWithError:(NSError *)error {
    [MBProgressHUD showHint:@"服务器连接失败，不能推流。。" toView:[UIApplication sharedApplication].keyWindow];
    
    if (self.delegate && [[self delegate] respondsToSelector:@selector(disConnecedCallback)]) {
        [self.delegate disConnecedCallback];
    }
    //自动连接
//    [self startConnect];
}
- (void)didConnectToHost:(NSString *)host port:(UInt16)port {
    [MBProgressHUD showHint:@"服务器连接成功，准备推流。。" toView:[UIApplication sharedApplication].keyWindow];
    if (self.delegate && [[self delegate] respondsToSelector:@selector(ConnecedCallback)]) {
        [self.delegate ConnecedCallback];
    }
}

- (void)didReceiveData:(NSData *)data tag:(long)tag {
//    NSLog(@"====%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //恢复线程
//    dispatch_resume(_dataQueue);
    
}

- (void)didWriteTag:(long)tag {
    
}

- (void)deleteFileAfterSendOver:(NSString *)path {
    //数据发送完成,删除文件
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmartKiller"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
//        NSLog(@"文件将被删除。。。%@",path);
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

@end
