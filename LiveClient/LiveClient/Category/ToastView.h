//
//  ToastView.h
//  QQMusicPad
//
//  Created by Rainkey Shen on 3/22/11.
//  Copyright 2011 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PopPostion_s
{
    LayoutTop,
    LayoutMiddle,
    LayoutBottom
}PopPostion;

@interface ToastView : UIView {
    UIImageView *bgView;
    UIImageView *imageView;
    UILabel *contentView;
	PopPostion _layout;
    UIView *_parentView;
    NSInteger initType;
}

+ (void) popToastWithText:(NSString*)message;

+ (ToastView*) popToastWithTextMode:(NSString*)message;

+ (void) popToastWithImage:(UIImage*)showImage;
+ (void) popToastInView:(UIView*)parentView
              withText:(NSString*)message
             imageName:(NSString*)imageName
                layout:(PopPostion)layout
         hasBackground:(BOOL)hasBg;

- (id) initToastWithText:(NSString*)message;

- (id) initToastWithImage:(UIImage*)image;

- (void) show;

- (void) show:(NSInteger)duration;

- (void) hide;

@end
