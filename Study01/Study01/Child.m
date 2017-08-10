//
//  Child.m
//  Study01
//
//  Created by 小布丁 on 2017/5/19.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "Child.h"

@implementation Child

+ (void)load {
    NSLog(@"%@",NSStringFromClass([self class]));
    NSLog(@"%@",NSStringFromClass([super class]));
}
                 
@end
