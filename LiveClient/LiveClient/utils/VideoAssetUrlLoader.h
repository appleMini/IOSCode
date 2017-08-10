//
//  VideoAssetUrlLoader.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/15.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef NS_ENUM(NSInteger, AssetUrlLoaderType) {
    AssetUrlLocationLoader = 0, //缓冲完成
    AssetUrlLiveLoader, //无缓存
    AssetUrlCacheLoader, //正在缓冲
};

@protocol VideoAssetUrlLoaderDelegate;
@interface VideoAssetUrlLoader : NSObject <AVAssetResourceLoaderDelegate>
@property (nonatomic, weak) id<VideoAssetUrlLoaderDelegate> delegate;
@property (nonatomic, assign) AssetUrlLoaderType type;
@property (nonatomic, assign) BOOL seekRequire;

- (NSURL *)getSchemeVideoURL:(NSURL *)url;

- (BOOL)canMove:(CGFloat)Progress;

@end

@protocol  VideoAssetUrlLoaderDelegate <NSObject>
- (void)loaderDidFailWithError;
- (void)cacheProgress:(CGFloat)progress;
- (void)finishedCache:(NSURL *)url;

@end
