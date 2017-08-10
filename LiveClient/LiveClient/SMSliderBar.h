//
//  SMSliderBar.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/11.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SMSliderBarType) {
    SMSliderURLType = 0,  //可以拉动，但是必须在一缓存的区域
    SMSliderLocationType, //可以拉动，但是没有缓存
    SMSliderLiveType   //不可以拉动
};

@protocol  SMSliderDelegate;

@interface SMSliderBar : UIView
@property (nonatomic, assign) BOOL isAllowDrag;
@property (nonatomic, weak) id <SMSliderDelegate> delegate;
@property (nonatomic, assign) SMSliderBarType type;
@property (nonatomic, weak) UIColor *progressBgColor;
@property (nonatomic, assign) NSTimeInterval endBufferValue;
@property (nonatomic, assign) NSTimeInterval startBufferValue;
@property (nonatomic, assign) NSTimeInterval value;

@end

@protocol SMSliderDelegate <NSObject>

- (void)SMSliderBar:(UIView *)slider valueChanged:(float)value;
- (void)SMSliderBarBeginTouch:(UIView *)slider;
- (void)SMSliderBarEndTouch:(UIView *)slider;

@end
