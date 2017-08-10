//
//  ObserverTestViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "ObserverTestViewController.h"

@interface ObserverTestViewController ()

@end

@implementation ObserverTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 80, 60)];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.titleLabel.text = @"change";
    [btn setTitle:@"change" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)change:(id)sender {
    int num = arc4random() % 20;
    
    self.text = [NSString stringWithFormat:@"abcd%d", num];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_NOTIFICATION" object:nil];
}

- (void)dealloc {
    NSLog(@"======释放了======");
}

@end
