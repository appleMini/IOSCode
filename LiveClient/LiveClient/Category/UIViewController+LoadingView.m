//
//  UIView+LoadingView.m
//  LiveClient
//
//  Created by 小布丁 on 2017/2/22.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "UIViewController+LoadingView.h"

@implementation UIViewController(LoadingView)

- (void)showLoadingView {
    //转轮
    UIActivityIndicatorView *waitView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    waitView.tag = 1000;
    waitView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    waitView.backgroundColor = [UIColor blackColor];
    waitView.alpha = 0.5f;

    waitView.layer.cornerRadius = 4;
    waitView.layer.masksToBounds = YES;
    waitView.hidesWhenStopped = YES;
    waitView.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    [self.view addSubview:waitView];
    [self.view bringSubviewToFront:waitView];
    
    [waitView startAnimating];
}

- (void)dismissLoadingView {
    UIActivityIndicatorView *waitView = (UIActivityIndicatorView *)[self.view viewWithTag:1000];
    [waitView stopAnimating];
    
    [waitView removeFromSuperview];
}

@end
