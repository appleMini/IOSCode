//
//  BlockObject.m
//  Study01
//
//  Created by 小布丁 on 2017/7/7.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "BlockObject.h"

@implementation BlockObject

- (void)test:(StrongBlock)block {
    if (block) {
        self.sblock = [block copy];
        
        self.sblock();
    }
}

@end
