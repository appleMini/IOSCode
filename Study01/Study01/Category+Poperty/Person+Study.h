//
//  Person+Study.h
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Person(Study)

@property (nonatomic, copy) NSString *school;
@property (nonatomic, assign) int score;

- (void)print;
@end
