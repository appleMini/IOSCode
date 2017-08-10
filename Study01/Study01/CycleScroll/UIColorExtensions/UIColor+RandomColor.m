//
//  UIColor+RandomColor.m
//  Study01
//
//  Created by 小布丁 on 2017/7/6.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "UIColor+RandomColor.h"

@implementation UIColor(RandomColor)

+ (UIColor *)randomColor {
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
    
}

@end
