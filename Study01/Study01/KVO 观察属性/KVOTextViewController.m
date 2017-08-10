//
//  KVOTextViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/7/21.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "KVOTextViewController.h"

@interface KVOTextViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UITextField *textField4;

@property (nonatomic, copy) void(^textValueChangeBlock)(NSString *);
@end

@implementation KVOTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //添加监听事件
//    [self addTargetMethod];
    //全局通知
//    [self addNSNotificationCenter];
    //KVO
    [self addKVO];
    //代理
//    [self addDelegate];
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [self.textField1 addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
}
-(void)textField1TextChange:(UITextField *)textField{
    NSLog(@"textField1 - 输入框内容改变,当前内容为: %@",textField.text);
}

#pragma mark - NSNotificationCenter 添加监听方法
-(void)addNSNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textField2TextChange:) name:UITextFieldTextDidChangeNotification object:self.textField2];
}
-(void)textField2TextChange:(NSNotification *)noti{
    UITextField *currentTextField = (UITextField *)noti.object;
    NSLog(@"textField2 - 输入框内容改变,当前内容为: %@",currentTextField.text);
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //内存泄漏  不移除监听会造成崩溃 但是在 dealloc 中移除 不起作用，控制器无法释放
    [self.textField3 removeObserver:self forKeyPath:@"text" context:nil];
}

#pragma mark - KVO : 注意这种方法不会直接监听键盘输入而是监听 textField.text 的改变,代码设置才会有效
-(void)addKVO{
    [self.textField3 addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    self.textField3.text = @"123";
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"text"] && object == self.textField3) {
        NSLog(@"textField3 - 输入框内容改变,当前内容为: %@",self.textField3.text);
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
//-(void)dealloc{
//    [self.textField3 removeObserver:self forKeyPath:@"text" context:nil];
//}

#pragma mark - 代理
-(void)addDelegate{
    //实现 UITextFieldDelegate 协议
    self.textField4.delegate = self;
}
#pragma mark  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}// return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textField4 - 开始编辑");
}// became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textField4 - 结束编辑");
}// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0){
    
}// if implemented, called in place of textFieldDidEndEditing:

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"textField4 - 正在编辑, 当前输入框内容为: %@",textField.text);
    return YES;
}// return NO to not change text

//-(void)dealloc{
//    [self.textField3 removeObserver:self forKeyPath:@"text" context:nil];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
