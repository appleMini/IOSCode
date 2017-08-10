//
//  NSArray+Safe.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "NSMutableArray+Safe.h"
#import <objc/runtime.h>

@implementation NSMutableArray(Safe)

-(void) safeAddObject:(id)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}
@end
