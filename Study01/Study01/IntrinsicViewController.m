//
//  IntrinsicViewController.m
//  Study01
//
//  Created by 小布丁 on 2017/6/26.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "IntrinsicViewController.h"

@interface IntrinsicViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;

@end

@implementation IntrinsicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)changeText:(id)sender {
    
    int count = arc4random() % 10;
    NSString *msg =  [NSString stringWithFormat:@"%d我想说说。。。。。。",count];
    
    NSMutableString *str = [NSMutableString stringWithString:msg];
    
    for (int i=0; i<count; i++) {
        [str appendString:msg];
    }
    
    self.label2.text = str;
    
    self.label3.text = str;
    
    self.label5.text = str;
    self.label6.text = str;
}



@end
