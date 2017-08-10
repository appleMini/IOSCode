//
//  ViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/5/3.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "ViewController.h"
#import "CustomLabel.h"
#import "CustomAlertViewController.h"
#import "PopBoxAction.h"
#import "NSObject+KVO.h"

#import <objc/runtime.h>

@interface Message : NSObject

@property (nonatomic, copy) NSString *text;

@end

@implementation Message

@end

@interface ViewController ()

@property (copy, nonatomic) NSString *text;
@property (weak, nonatomic) IBOutlet CustomLabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;

@property (nonatomic, strong) Message *message;

@end

@implementation ViewController

- (void)dealloc {
    [self.message PG_removeObserver:self forKey:@"Text"];
    [self removeObserver:self forKeyPath:@"text"];
}

//在声明Block之后、调用Block之前对全局变量进行修改,在调用Block时全局变量值是修改之后的新值
// 声明全局变量global
// 调用后控制台输出"global = 104"
int global = 100;
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    void(^myBlock)() = ^{
        global++;
        NSLog(@"global = %d", global);
    };
    global = 103;
    // 调用后控制台输出"global = 101"
    myBlock();
    
    ///使用dispatch_set_target_queue将多个串行的queue指定到了同一目标，那么着多个串行queue在目标queue上就是同步执行的，不再是并行执行。
    /*
    dispatch_queue_t targetQueue = dispatch_queue_create("target_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_set_target_queue(queue1, targetQueue);
    dispatch_set_target_queue(queue2, targetQueue);
    
    
    dispatch_async(queue2, ^{
        NSLog(@"do job3");
        [NSThread sleepForTimeInterval:10.f];
    });
    
    dispatch_async(queue1, ^{
        NSLog(@"do job1");
        [NSThread sleepForTimeInterval:3.f];
    });
    
    dispatch_async(queue2, ^{
        NSLog(@"do job2");
        [NSThread sleepForTimeInterval:1.f];
    });
     */
    
    //block 执行是否在 主线程 要看 GCD 是 同步执行还是异步执行，与并行队列或是串行队列无关
    /*
    
    NSLog(@"==========%@",[NSThread currentThread]);
    
    dispatch_queue_t serialQ = dispatch_queue_create("www.test.com", DISPATCH_QUEUE_SERIAL);
    
    void (^block1) () = ^{
        dispatch_sync(serialQ, ^{
            NSLog(@"Block1 balalalala");
            NSLog(@"%@",[NSThread currentThread]);
        });
//        dispatch_async(serialQ, ^{
//            NSLog(@"Block1 balalalala");
//            NSLog(@"%@",[NSThread currentThread]);
//        });
    };
    
    block1();
     */
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"print  1....");
//    });
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"print  1....");
//    });
//    
//    // insert code here...
//    NSLog(@"Hello, World!");
//    
////    dispatch_async(dispatch_get_main_queue(), ^{
////        NSLog(@"print  2....");
////    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"print  2....");
//    });

//    for (int i=0; i < 1000; i++) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSLog(@"print  1....  %@",[NSThread currentThread]);
//        });
//    }

}

- (UIImage *)kt_drawRectWithRoundedCorner {
    UIImage *iconImg = [UIImage imageNamed:@"Icon-60"];
    
    CGRect rect = self.iconIV.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(rect.size.width, rect.size.height)];
    
    CGContextAddPath(ctx, path.CGPath);
    
    CGContextClip(ctx);
    
    [iconImg drawInRect:rect];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width/2.0];
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:241.0/255 green:241.0/255 blue:241.0/255 alpha:1.0].CGColor);
    CGContextSetLineWidth(ctx, 10.0);
    CGContextAddPath(ctx, path2.CGPath);
    CGContextStrokePath(ctx);
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}

- (IBAction)alertAction:(id)sender {
    
    CustomAlertViewController *alertVC = [[CustomAlertViewController alloc] initWithNibName:@"CustomAlertViewController" bundle:nil];
    
    PopBoxAction *cancel = [[PopBoxAction alloc] initWithActName:@"haode" actionStyle:ActionStyleDefault action:^{
        NSLog(@"==========================");
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.label.text = @"www.baidu.com";
    self.label.backgroundColor = [UIColor redColor];
    
    self.iconIV.image = [self kt_drawRectWithRoundedCorner];
    
    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    
    self.message = [[Message alloc] init];
    [self.message PG_addObserver:self forKey:@"text"
                       withBlock:^(id observedObject, NSString *observedKey, id oldValue, id newValue) {
                           NSLog(@"%@.%@ is now: %@", observedObject, observedKey, newValue);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               self.label.text = newValue;
                           });
                           
                       }];
    [self cf_KeysWithValues];
    
}

- (void)cf_KeysWithValues {
    unsigned int count ,i;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &count);
    
    for (i = 0; i < count; i++) {
        objc_property_t property = propertyArray[i];
        NSLog(@"=======property======%@", [NSString stringWithCString:property_getName(property) encoding:kCFStringEncodingUTF8]);
    }
    free(propertyArray);
    
    Ivar *vars = class_copyIvarList([self class], &count);
    for (i = 0; i < count; i++) {
        NSString *ivar = [NSString stringWithCString:ivar_getName(vars[i]) encoding:kCFStringEncodingUTF8];
        NSLog(@"=======Ivar======%@", ivar);
    }
    free(vars);
}

- (IBAction)callClick:(id)sender {
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"10086"];
    // NSLog(@"str======%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    
    self.text = @"www.hao123.com";
    
    
    NSArray *msgs = @[@"Hello World!", @"Objective C", @"Swift", @"Peng Gu", @"peng.gu@me.com", @"www.gupeng.me", @"glowing.com"];
    NSUInteger index = arc4random_uniform((u_int32_t)msgs.count);
    self.message.text = msgs[index];
    
    //[NSURL URLWithString:@"study222:"]
    NSURL *url = [NSURL URLWithString:@"study222:"];
    
    //先判断是否能打开该url
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //打开url
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }else {
        //给个提示或者做点别的事情
        NSLog(@"U四不四洒，没安装WXApp，怎么打开啊！");
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"text"]) {
        
        NSString *text = change[NSKeyValueChangeNewKey];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.label.text = text;
        });
    }
}
@end
