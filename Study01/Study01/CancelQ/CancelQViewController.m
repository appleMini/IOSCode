//
//  CancelQViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "CancelQViewController.h"
typedef void (^CycleBlock) ();

@interface CancelQViewController () {
    BOOL _isCanceled;
}

@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (nonatomic, strong) dispatch_queue_t serialQ;
@property (nonatomic, copy) CycleBlock cblock;
@property (nonatomic, strong) NSMutableArray *blockArray;

@end

@implementation CancelQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _serialQ = dispatch_queue_create("www.test.com", DISPATCH_QUEUE_SERIAL);
    _blockArray = [NSMutableArray arrayWithCapacity:10];
    for (int i=0; i< 10; i++) {
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_DETACHED, ^{
            //            if (_isCanceled) {
            //                return ;
            //            }
            NSLog(@"正在执行===%d",i);
            [NSThread sleepForTimeInterval:1.3];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showLabel.text = [NSString stringWithFormat:@"%d执行完成", i];
            });
        });
        
        [self.blockArray addObject:block];
        dispatch_async(_serialQ, block);
    }
    
    /**
     解决循环引用的 三种方法：1.__weak 2.__unsafe__unretained (当对象释放，会crash，因为释放后，地址还是之前的地址，野指针) 3.block 执行完成后 置nil(缺点：Block 只能执行一次)
    
    __unsafe_unretained typeof(self) ws = self;
//    __weak typeof(self) ws = self;
    self.cblock = ^{
        NSLog(@"正在执行===========%@",ws);
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.showLabel.text = [NSString stringWithFormat:@"执行完成"];
        });
    };
    
    self.cblock();
//    self.cblock = nil;
     */
    
}
- (IBAction)cancelAction:(id)sender {
//    _isCanceled = YES;
    
    for (dispatch_block_t block in _blockArray) {
        dispatch_block_cancel(block);
    }
    
    [_blockArray removeAllObjects];
    _blockArray = nil;
//    dispatch_suspend(_serialQ);
////    dispatch_release(_serialQ);
//    _serialQ = nil;
}


- (void)dealloc {
    NSLog(@"，，，，，，，，释放了，，，，，，，，，");
}

@end
