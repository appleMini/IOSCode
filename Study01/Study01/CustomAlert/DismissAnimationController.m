//
//  DismissAnimationController.m
//  UICoreLibrary
//
//  Created by 小布丁 on 2016/11/24.
//  Copyright © 2016年 小布丁. All rights reserved.
//

#import "DismissAnimationController.h"

@interface DismissAnimationController ()<UIViewControllerAnimatedTransitioning>

@end

@implementation DismissAnimationController

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:3.0 * duration / 4.0
                          delay:duration / 4.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         fromViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [fromViewController.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
    
    [UIView animateWithDuration:2.0 * duration
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:-15.0
                        options:0
                     animations:^{
                         fromViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
                     }
                     completion:nil];
}

@end
