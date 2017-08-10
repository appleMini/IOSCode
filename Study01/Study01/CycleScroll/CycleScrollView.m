//
//  CycleScrollView.m
//  Study01
//
//  Created by 小布丁 on 2017/7/6.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "CycleScrollView.h"
#import "UIColor+RandomColor.h"
@interface CycleScrollView()

@property (nonatomic, copy) NSArray *imgArray;
@end

@implementation CycleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupViews:frame];
    }
    
    return self;
}

- (void)setupViews:(CGRect)frame {
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    self.contentSize = CGSizeMake(3 * width, height);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:3];
    CGFloat x = 0;
    for (int i=0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
        
        imgView.backgroundColor = [UIColor randomColor];
        [self addSubview:imgView];
        
        [arr addObject:imgView];
        x += width;
    }
    
    self.imgArray = [NSArray arrayWithArray:arr];
    
    self.contentOffset = CGPointMake(width, 0);
    self.showsHorizontalScrollIndicator = YES;
    self.showsVerticalScrollIndicator = NO;
    self.alwaysBounceVertical = NO;
    self.pagingEnabled = YES;
    self.delegate = self;
}

#pragma  -mark 加载 图片
- (void)loadImage {
    UIImageView *imgV0 = self.imgArray[0];
    imgV0.backgroundColor = [UIColor randomColor];
    
    UIImageView *imgV = self.imgArray[2];
    imgV.backgroundColor = [UIColor randomColor];
}

#pragma -mark scroll 滚动代理
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"将要开始滑动、、、、、、");
//    NSLog(@"==将要开始滑动===%f",scrollView.contentOffset.x);
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"======%f",scrollView.contentOffset.x);
    NSLog(@"滚动来了、、、、、、");
    
    CGFloat width = scrollView.bounds.size.width;
    if (scrollView.contentOffset.x <= 40) {
        NSLog(@"<= 40 .........");
        UIImageView *imgV0 = self.imgArray[0];
        
        UIImageView *imgV = self.imgArray[1];
        imgV.backgroundColor = imgV0.backgroundColor;
    }else if(scrollView.contentOffset.x >= (2*width-40)) {
        NSLog(@">= 40 .........");
        
        UIImageView *imgV2 = self.imgArray[2];
        
        UIImageView *imgV = self.imgArray[1];
        imgV.backgroundColor = imgV2.backgroundColor;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"滚动结束、、、、、");
    CGFloat width = scrollView.bounds.size.width;
    
    scrollView.contentOffset = CGPointMake(width, 0);
    [self loadImage];
}

@end
