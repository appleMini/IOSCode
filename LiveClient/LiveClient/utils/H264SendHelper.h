//
//  H264SendHelper.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/27.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol H264SendHelperConnectionDelegate <NSObject>
- (void)ConnecedCallback;
- (void)disConnecedCallback;
@end

@interface H264SendHelper : NSObject

@property (nonatomic,weak) id<H264SendHelperConnectionDelegate> delegate;

+ defaultH264SendHelper;
- (void)sendPacketWithPath:(NSString *)path  withACCPath:(NSString *)accpath withDuration:(NSTimeInterval)durate;
- (void)sendPacket:(NSData *)data withTag:(long)tag;
- (void)disConnection;
- (void)startConnect;
@end
