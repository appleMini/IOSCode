//
//  BlockObject.h
//  Study01
//
//  Created by 小布丁 on 2017/7/7.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^StrongBlock)();
@interface BlockObject : NSObject

@property (nonatomic, copy)StrongBlock sblock;

- (void)test:(StrongBlock) block;

@end
