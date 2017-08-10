//
//  SMSliderBar.m
//  LiveClient
//
//  Created by 小布丁 on 2017/3/11.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "SMSliderBar.h"
@interface SMSliderBar()

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (assign, nonatomic) BOOL isCanMovie;                      //是否可以移动
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startBufferConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bufferWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *bufferView;

@property (strong, nonatomic) IBOutlet UIView *view;


@end

@implementation SMSliderBar
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
        self.slider.minimumValue = 0;
        self.slider.maximumValue = 100;
        self.slider.value = 0;
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"SMSliderBar" owner:self options:nil];
    self.view.frame = CGRectZero;
    [self addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)setValue:(NSTimeInterval)value {
    _value = value;
    self.slider.value = value * 100;
}

- (void)setType:(SMSliderBarType)type {
    _type = type;
    
    self.startBufferValue = 0;
    self.endBufferValue = 0;
}

- (void)setEndBufferValue:(NSTimeInterval)endBufferValue {
    _endBufferValue = endBufferValue;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.startBufferConstraint.constant = _startBufferValue / 100 * self.frame.size.width;
    self.bufferWidthConstraint.constant = _endBufferValue / 100 * self.frame.size.width;
    
    [self updateConstraintsIfNeeded];
}

- (void)setIsAllowDrag:(BOOL)isAllowDrag {
    _isAllowDrag = isAllowDrag;
    
    self.userInteractionEnabled = isAllowDrag;
    
    if (self.type == SMSliderLiveType) {
        self.userInteractionEnabled = NO;
    }

    self.slider.userInteractionEnabled = NO;
}

- (void)setProgressBgColor:(UIColor *)progressBgColor
{
    self.bufferView.backgroundColor = progressBgColor;
}

- (BOOL)hitSliderTest:(CGPoint)point {
//    NSLog(@"===========%f",point.x * 100 / self.frame.size.width);
    float  v =  point.x * 100 / self.frame.size.width;
    if( v >= (self.slider.value-2) && v <= (self.slider.value+2)){
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.isCanMovie = NO;
    //判断触摸点 是否在slider 的 显示点 上
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if(![self hitSliderTest:point]){
        return;
    }

    self.isCanMovie = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(SMSliderBarBeginTouch:)]){
        [self.delegate SMSliderBarBeginTouch:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(!self.isCanMovie){
        return;
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    self.value =  point.x / self.frame.size.width;
//    NSLog(@"===============value=======%f",self.value);
    if(self.delegate && [self.delegate respondsToSelector:@selector(SMSliderBar: valueChanged:)]){
        [self.delegate SMSliderBar:self valueChanged:self.slider.value/100];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(!self.isCanMovie){
        return;
    }
    
    self.isCanMovie = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(SMSliderBarEndTouch:)]){
        [self.delegate SMSliderBarEndTouch:self];
    }
}
#pragma -mark slider 下面方法在拖拽的时候很流畅，效果很好，但是点击的时候dragEnd 不会调用，出现不能播放的bug
//- (IBAction)valueChange:(UISlider *)mslider {
////    NSLog(@"正在滑动=====%f",mslider.value);
//    self.value = mslider.value / 100;
//    if(self.delegate && [self.delegate respondsToSelector:@selector(SMSliderBar: valueChanged:)]){
//        [self.delegate SMSliderBar:self valueChanged:self.slider.value/100];
//    }
//}
//
//- (IBAction)dragEnd:(UISlider *)mslider {
////    NSLog(@"结束滑动%f",mslider.value);
//    if(self.delegate && [self.delegate respondsToSelector:@selector(SMSliderBarEndTouch:)]){
//        [self.delegate SMSliderBarEndTouch:self];
//    }
//}

@end
