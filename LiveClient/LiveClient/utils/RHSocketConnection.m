//
//  RHSocketConnection.m
//  LiveClient
//
//  Created by 小布丁 on 2017/2/20.
//  Copyright © 2017年 小布丁. All rights reserved.
//
#import "RHSocketConnection.h"
#import "GCDAsyncSocket.h"

@interface RHSocketConnection () <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_asyncSocket;
}

@end

@implementation RHSocketConnection

- (instancetype)init
{
    if (self = [super init]) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
}

- (void)connectWithHost:(NSString *)hostName port:(int)port withDelegate:(id<RHSocketConnectionDelegate>)delegate
{
    self.delegate = delegate;
    
    NSError *error = nil;
    [_asyncSocket connectToHost:hostName onPort:port withTimeout:30 error:&error];
    if (error) {
        RHSocketLog(@"[RHSocketConnection] connectWithHost error: %@", error.description);
        if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
            [_delegate didDisconnectWithError:error];
        }
    }
}

- (void)disconnect
{
    [_asyncSocket disconnect];
}

- (BOOL)isConnected
{
    return [_asyncSocket isConnected];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket readDataWithTimeout:timeout tag:tag];
}

- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag
{
    [_asyncSocket writeData:data withTimeout:timeout tag:tag];
}

- (void)sayByebye{
    [_asyncSocket writeData:[@"Byebye" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:-1];
}

#pragma mark -
#pragma mark GCDAsyncSocketDelegate method

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    RHSocketLog(@"[RHSocketConnection] didDisconnect...%@", err.description);
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [_delegate didDisconnectWithError:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    RHSocketLog(@"[RHSocketConnection] didConnectToHost: %@, port: %d", host, port);
    if (_delegate && [_delegate respondsToSelector:@selector(didConnectToHost:port:)]) {
        [_delegate didConnectToHost:host port:port];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    RHSocketLog(@"[RHSocketConnection] didReadData length: %lu, tag: %ld", (unsigned long)data.length, tag);
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveData:tag:)]) {
        [_delegate didReceiveData:data tag:tag];
    }
    [sock readDataWithTimeout:-1 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    RHSocketLog(@"[RHSocketConnection] didWriteDataWithTag: %ld", tag);
    if (_delegate && [_delegate respondsToSelector:@selector(didWriteTag:)]) {
        [_delegate didWriteTag:tag];
    }
//    [sock readDataWithTimeout:-1 tag:tag];
}

@end
