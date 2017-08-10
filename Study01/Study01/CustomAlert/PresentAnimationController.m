//
//  PresentAnimationController.m
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/24.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import "PresentAnimationController.h"
#import "Masonry.h"

@interface PresentAnimationController ()<UIViewControllerAnimatedTransitioning>

@end

@implementation PresentAnimationController
//- (instancetype)initWithToViewContentSize:(CGSize)
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *markeView = [[UIView alloc] initWithFrame:containerView.bounds];
    markeView.backgroundColor = [UIColor blackColor];
    markeView.alpha = 0.5;
    [containerView addSubview:markeView];
    
    [markeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0.0);
        make.trailing.mas_equalTo(0.0);
        make.top.mas_equalTo(0.0);
        make.bottom.mas_equalTo(0.0);
        
    }];
//    CGRect frame = containerView.bounds;
//    frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(40.0, 40.0, 200.0, 40.0));
    CGSize contentSize = toViewController.preferredContentSize;
//    CGFloat x = (SCREEN.size.width - contentSize.width)/2;
//    CGFloat y = (SCREEN.size.height - 64 - contentSize.height)/2;
//    toViewController.view.frame = CGRectMake(x, y, contentSize.width, contentSize.height);
    [containerView addSubview:toViewController.view];
    
    [toViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(contentSize.width);
        make.height.mas_equalTo(contentSize.height);
        make.center.mas_offset(0);
    }];
    
    //若动画中scale从大于0的值开始同时alpha从0到1，则可以让你动画速度比简单的scale从0到1更快。试着删除alpha动画，再和从0开始的scale动画比较。
    toViewController.view.alpha = 0.0;
    toViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration / 2.0 animations:^{
        toViewController.view.alpha = 1.0;
    }];
    
    CGFloat damping = 0.55;
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
