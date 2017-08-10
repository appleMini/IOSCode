//
//  NSArrayViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "NSArrayViewController.h"
#import "NSMutableArray+Safe.h"

@interface NSArrayViewController ()

@end

@implementation NSArrayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *dict = @{@"name": @"xiaoxiao",
                           @"score": @"99"
                           };
    
    NSString *name = dict[@"name"];
    NSString *str = dict[@"school"];
    [dict objectForKey:@""];
//    NSString *a = [dict valueForKey:@"@abcnd"];
    
    NSMutableArray *array = [NSMutableArray array];
    [array safeAddObject:name];
//    [array addObject:str];
    [array safeAddObject:str];
    
    NSLog(@"===========%@",array);
}

@end
