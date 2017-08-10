//
//  CategoryViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "CategoryViewController.h"
#import "Person+Study.h"
#import "Person+safe.h"
#import <objc/runtime.h>
#import "BlockObject.h"
#import "UIViewController+Clazz.h"
#import "Son.h"

@interface CategoryViewController ()

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) BlockObject *boj;

@end

@implementation CategoryViewController

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"CategoryViewController viewDidAppear ");
    
    //重复添加timer
//    _timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = back;

    Person *p1 = [Person sharePerson];
    Person *p2 = [Person new];
    
    Person *p = [[Person alloc] init];
    unsigned int count;
    Ivar *ivars = class_copyIvarList([p class], &count);
    for(int i=0; i< count; i++) {
        const char *ivarName = ivar_getName(ivars[i]);
        
        NSLog(@"ivarname=======%s",ivarName);
    }
    
    free(ivars);
    
    
    unsigned int mcount;
    Method *method = class_copyMethodList([p class], &mcount);
    for(int i=0; i< mcount; i++) {
        SEL methodSel = method_getName(method[i]);
        NSString *name = NSStringFromSelector(methodSel);
        NSLog(@"methodName=======%@",name);
    }
    
    free(method);
    
    unsigned int pcount;
    objc_property_t *property = class_copyPropertyList([p class], &pcount);
    for(int i=0; i< pcount; i++) {
        const char *pName = property_getName(property[i]);
        
        NSLog(@"pName=======%s",pName);
    }
    
    free(property);
    
    p.school = @"北京大学";
    
    NSLog(@"===shcool===%@",p.school);
    
    [p show];
    
    Son *son = [[Son alloc] init];
    son.score = 100;
    
    _timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"abcd",@"cdf", nil];
    void (^block) () = ^{
        self.titleName = @"abcdfff";
        NSLog(@"=========%@", self.titleName);
        [arr addObject:@"cddd"];
        NSLog(@"===== %@",arr);
        [arr removeAllObjects];
        NSLog(@"===== %@",arr);
    };
    
    block();
    
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
    
    BlockObject *bj = [[BlockObject alloc] init];
    self.boj = bj;
    
    __weak typeof(self) ws = self;
    [bj test:^{
        if (ws) {
            __strong typeof(ws) stongWS = ws;
            NSLog(@"=======%@",stongWS);
        }

    }];
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(self)));
    
}

- (void)backAction:(id)sender {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timerAction {
    NSLog(@"timer is  running ...........");
}

- (void)dealloc {
    NSLog(@"释放了。。。。。。。。。。。。。");
}

@end
