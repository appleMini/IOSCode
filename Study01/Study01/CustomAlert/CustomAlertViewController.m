//
//  CustomAlertViewController.m
//  CDBMeap
//
//  Created by 小布丁 on 2017/5/8.
//  Copyright © 2017年 yonyou. All rights reserved.
//

#import "CustomAlertViewController.h"
#import "PresentAnimationController.h"
#import "DismissAnimationController.h"
#import "PopBoxAction.h"
#import "Masonry.h"
#import <objc/runtime.h>

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

@interface CustomAlertViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (nonatomic, strong) NSMutableArray<PopBoxAction *> *actions;
@end

@implementation CustomAlertViewController

- (CGSize)preferredContentSize
{
    return self.alertView.frame.size;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)    nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _actions = [[NSMutableArray alloc] init];
        
        //设置弹出的样式为Custom
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadActionButton];
}

- (void)loadActionButton {
    for (int i=0; i< _actions.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectZero;
        btn.tag = i+10;
        [btn setTitle:_actions[i].actName forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        if (_actions[i].style == ActionStyleImp) {
            [btn setTitleColor:RGB(39, 162, 226) forState:UIControlStateNormal];
        }
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        objc_setAssociatedObject(btn, @"action", _actions[i].action, OBJC_ASSOCIATION_COPY);
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.actionView addSubview:btn];
        
        CGFloat width = self.actionView.frame.size.width / _actions.count;
        CGFloat x = width * i;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(x);
            make.centerY.mas_offset(0);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(self.actionView.frame.size.height);
        }];
    }

}

- (void)btnAction:(UIButton *)btn
{
    ActionBlock block = objc_getAssociatedObject(btn, @"action");
    block();
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)addAction:(PopBoxAction *)act
{
    if (_actions && ![_actions containsObject:act]) {
        __weak typeof(self) weakSelf = self;
        
        ActionBlock oldBlock = [act.action copy];
        ActionBlock block = ^{
            oldBlock();
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        
        act.action = [block copy];
        [_actions addObject:act];
    }
}

#pragma -mark UIViewControllerTransitioningDelegate
- (id)animationControllerForPresentedController:(UIViewController *)presented
                           presentingController:(UIViewController *)presenting
                               sourceController:(UIViewController *)source
{
    return [[PresentAnimationController alloc] init];
}

- (id)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[DismissAnimationController alloc] init];
}
@end
