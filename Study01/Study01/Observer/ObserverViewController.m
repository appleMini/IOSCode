//
//  ObserverViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "ObserverViewController.h"
#import "ObserverTestViewController.h"

@interface ObserverViewController ()

@end

@implementation ObserverViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"LOGIN_NOTIFICATION" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        NSLog(@"====change======");
    }
}

- (IBAction)changeAction:(id)sender {
    ObserverTestViewController *vc = [[ObserverTestViewController alloc] init];
    [vc addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [vc addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)login {
    NSLog(@"login ----------");
}


- (void)dealloc {
    NSLog(@"observer  释放了、、、、、、、");
}
@end
