//
//  RHSocketConfig.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/20.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef RHSocketConfig_h
#define RHSocketConfig_h


#ifdef DEBUG
#define RHSocketLog(fmt, ...) NSLog((@"[%s[line:%d]] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#endif

#endif /* RHSocketConfig_h */
