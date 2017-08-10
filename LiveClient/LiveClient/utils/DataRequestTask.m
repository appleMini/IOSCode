//
//  DataRequestTask.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/23.
//  Copyright © 2017年 小布丁. All rights reserved.
//
//抽象类的实现
#import "DataRequestTask.h"

@implementation DataRequestTask

- (instancetype)init
{
    if([self isMemberOfClass:[DataRequestTask class]]){
        
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }else{
        self = [super init];
    }
    
    return self;
}

- (void)start
{
    [self doesNotRecognizeSelector:_cmd];
    return;
}
@end
