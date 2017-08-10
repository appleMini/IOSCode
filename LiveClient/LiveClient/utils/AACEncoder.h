//
//  AACEncoder.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/19.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AACEncoder : NSObject

//@property (nonatomic) dispatch_queue_t encoderQueue;
//@property (nonatomic) dispatch_queue_t callbackQueue;

- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer completionBlock:(void (^)(NSData *encodedData, NSError* error))completionBlock;

- (void)stopAccEncode;
@end
