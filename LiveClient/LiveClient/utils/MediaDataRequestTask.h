//
//  MediaDataRequestTask.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataRequestTask.h"

#define Grain_Size 1024*1024*10-1 //缓存粒度（将整个视频分成10M一段下载）

@interface MediaDataRequestTask : DataRequestTask

@end
