//
//  UIViewController+Clazz.m
//  Study01
//
//  Created by 小布丁 on 2017/7/10.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "UIViewController+Clazz.h"

@implementation UIViewController(Clazz)

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"class == %@",NSStringFromClass([self class]));
}
@end
