//
//  PopBoxAction.m
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/22.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import "PopBoxAction.h"

@implementation PopBoxAction

- (instancetype)initWithActName:(nonnull NSString *)actName actionStyle:(ActionStyle)style action:(ActionBlock)action;
{
    self = [super init];
    if (self) {
        _actName = actName;
        _style = style;
        _action = [action copy];
    }
    
    return self;
}

@end
