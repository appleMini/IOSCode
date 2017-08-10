//
//  PopBoxAction.h
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/22.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
//操作
typedef void (^ActionBlock) ();

typedef NS_ENUM(NSInteger, ActionStyle) {
    ActionStyleDefault = 0,
    ActionStyleImp
};


@interface PopBoxAction : NSObject
@property (nonatomic, strong, readonly) NSString *actName;
@property (nonatomic, assign, readonly) ActionStyle style;
@property (nonatomic, copy) ActionBlock action;

//imp参数默认是NO,代表非主操作，如果传入YES 则是主操作,字体颜色会变为蓝色
- (instancetype)initWithActName:(NSString *)actName actionStyle:(ActionStyle)style action:(ActionBlock)action;

@end
