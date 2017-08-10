//
//  common.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/22.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef common_h
#define common_h

//x264 [warning]: non-strictly-monotonic PTS
#define ServerSocketAddr @"192.168.1.103"
#define ServerPORT 6666

#define kHost  @"http://192.168.1.103:8080/PLLiveService"

#ifdef DEBUG

#define NSSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else

#define NSSLog(...)

#endif

#endif /* common_h */
