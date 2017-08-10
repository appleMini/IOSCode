//
//  VedioModel.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/11.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface VideoModel : NSObject
WBSingletonH(VideoModel)

@property (nonatomic, strong) NSString      *subTitile;
@property (nonatomic, strong) NSString      *author;
@property (nonatomic, assign) double        duration;
@property (nonatomic, strong) NSURL         *strURL;
@property (nonatomic, assign) NSUInteger    rate;
@property (nonatomic, assign) NSUInteger    fps;
@property (nonatomic, assign) int           width;
@property (nonatomic, assign) int           height;
@property (nonatomic, assign) NSUInteger    fileLength;
@property (nonatomic, strong) NSString      *mimeType;

@end
