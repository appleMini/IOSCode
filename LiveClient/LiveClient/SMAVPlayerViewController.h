//
//  SMAVPlayerViewController.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/11.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

typedef NS_ENUM(NSInteger, PlayerType) {
    PlayerLocationType = 0,
    PlayerLocationLiveType,
    PlayerURLType,
    PlayerLiveType,
    PlayerNoLoaderURLType,
    PlayerVODType //流媒体
};

@interface SMAVPlayerViewController : UIViewController

@property (strong, nonatomic) VideoModel *video;

- (instancetype)initWithType:(PlayerType)type;

@end
