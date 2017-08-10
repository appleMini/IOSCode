//
//  PLBaseViewController.m
//  PLLiveCourse
//
//  Created by 小布丁 on 2017/2/14.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "PLBaseViewController.h"

@interface PLBaseViewController ()

@end

@implementation PLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.titleText;
        [titleLabel sizeToFit];
        titleLabel;
    });
}

@end
