//
//  CycleViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/6.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "CycleViewController.h"
#import "CycleScrollView.h"

@interface CycleViewController ()

@end

@implementation CycleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //调整 scroll 自动调整
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.navigationBar.translucent = false;
        // 边缘要延伸的方向
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        // 当Bar使用了不透明图片时，视图是否延伸至Bar所在区域
//        self.extendedLayoutIncludesOpaqueBars = NO;
        // scrollview是否自调整
//        self.automaticallyAdjustsScrollViewInsets = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
        // 去除半透明
//        self.tabBarController.tabBar.translucent = NO;
    }
    
    [self setupScrollView];
}

- (void)setupScrollView {
    CGRect rect = [UIScreen mainScreen].bounds;
    
    CycleScrollView *scrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 200)];
    
    scrollView.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrollView];
}

@end
