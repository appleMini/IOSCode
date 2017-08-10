//
//  RHSocketConnection.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/20.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RHSocketConfig.h"

@protocol RHSocketConnectionDelegate <NSObject>

@optional
- (void)didDisconnectWithError:(NSError *)error;
- (void)didConnectToHost:(NSString *)host port:(UInt16)port;
- (void)didReceiveData:(NSData *)data tag:(long)tag;
- (void)didWriteTag:(long)tag;

@end

@interface RHSocketConnection : NSObject

@property (nonatomic, weak) id<RHSocketConnectionDelegate> delegate;

- (void)connectWithHost:(NSString *)hostName port:(int)port withDelegate:(id<RHSocketConnectionDelegate>)delegate;
- (void)disconnect;

- (BOOL)isConnected;
- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)writeData:(NSData *)data timeout:(NSTimeInterval)timeout tag:(long)tag;
- (void)sayByebye;

@end
