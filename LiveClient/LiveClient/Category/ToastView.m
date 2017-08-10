//
//  ToastView.m
//  QQMusicPad
//
//  Created by Rainkey Shen on 3/22/11.
//  Copyright 2011 Tencent. All rights reserved.
//

#import "ToastView.h"
#import <QuartzCore/CALayer.h>

#define TEXT_TYPE (1)
#define IMAGE_TYPE (2)
#define CONTENT_MARGIN (40)
#define CONTENT_MARGIN_TOP (15)

static const NSInteger DEFAULT_DURATION = 1000;
static const NSInteger DISMISS_DURATION = 1000;

@implementation ToastView

+ (void) popToastWithText:(NSString *)message
{
    ToastView *toast = [[ToastView alloc] initToastWithText:message];
    [toast show: 2*DEFAULT_DURATION];
}

+ (ToastView *) popToastWithTextMode:(NSString *)message
{
    ToastView *toast = [[ToastView alloc] initToastWithText:message];
    [toast show:0];
    return toast;
}

+ (void) popToastWithImage:(UIImage *)showImage
{
    ToastView *toast = [[ToastView alloc] initToastWithImage:showImage];
    [toast show];
}

+ (void) popToastInView:(UIView *)parentView
               withText:(NSString *)message
              imageName:(NSString *)imageName
                 layout:(PopPostion)layout
          hasBackground:(BOOL)hasBg
{
    ToastView *toast = [[ToastView alloc] initToastInView:parentView
                                                 withText:message
                                                imageName:imageName
                                                   layout:layout
                                            hasBackground:hasBg];
    [toast show: 2*DEFAULT_DURATION];
}

- (id) initToastWithText:(NSString *)message
{
    self = [super initWithFrame:CGRectZero];
    initType = TEXT_TYPE;
    
    if (self && message) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
		
        UIImage *bgImage = [UIImage imageNamed:@"toast_bg.png"];
        CGSize imSize = bgImage.size;
        self.frame = CGRectMake(window.center.x-imSize.width/2, window.center.y-imSize.height/2, imSize.width, imSize.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        bgView  = [[UIImageView alloc] initWithImage:bgImage];
        bgView.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
        bgView.backgroundColor = [UIColor yellowColor];
        [self addSubview:bgView];
        
        contentView = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_MARGIN, CONTENT_MARGIN_TOP+200, bgImage.size.width-2*CONTENT_MARGIN,  bgImage.size.height-CONTENT_MARGIN)];
        contentView.backgroundColor = [UIColor blackColor];
        contentView.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        contentView.font = [UIFont systemFontOfSize:12];
        contentView.text = message;
        contentView.numberOfLines = 0;
        contentView.textAlignment = NSTextAlignmentCenter;
        contentView.layer.cornerRadius = 8;
        contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        contentView.layer.borderWidth = 1;
        [self addSubview:contentView];
    }
    return self;
}

- (id) initToastWithImage:(UIImage *)image
{
    self = [super initWithFrame:CGRectZero];
    initType = IMAGE_TYPE;
    
    if (self && image) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        
        CGSize imSize = image.size;
        self.frame = CGRectMake(window.center.x-imSize.width/2, window.center.y-imSize.height/2, imSize.width, imSize.height);
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, imSize.width, imSize.height);
        [self addSubview:imageView];
    }
    return self;
}

- (id) initToastInView:(UIView *)parentView
              withText:(NSString *)message
             imageName:(NSString *)imageName
                layout:(PopPostion)layout
         hasBackground:(BOOL)hasBg
{
    self = [super initWithFrame:CGRectZero];
    initType = TEXT_TYPE;
    _layout = layout;
    
    if (parentView) {
        _parentView = parentView;
    }else {
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        _parentView = [[window subviews] objectAtIndex:0];
    }
    
    if (self && message) {
        UIImage* bgImage = [UIImage imageNamed:imageName];
        CGSize imSize = bgImage.size;
        
        if(layout == LayoutTop) {
            self.frame = CGRectMake(parentView.center.x-imSize.width/2, parentView.center.y/2-imSize.height/2+20, imSize.width, imSize.height);
        }else if(layout == LayoutBottom) {
            self.frame = CGRectMake(parentView.center.x-imSize.width/2, parentView.center.y/2*3-imSize.height/2, imSize.width, imSize.height);
        }else {
            self.frame = CGRectMake(parentView.center.x-imSize.width/2, parentView.center.y-imSize.height/2, imSize.width, imSize.height);
        }
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        if(hasBg) {
            UIImage *bImage = [UIImage imageNamed:@"backgroundimage.png"];
            UIView *defaultBgView = [[UIImageView alloc] initWithImage:bImage];
            defaultBgView.frame = CGRectMake(0, 0, bImage.size.width,  bImage.size.height);
            [self addSubview:defaultBgView];
        }
        
        bgView = [[UIImageView alloc] initWithImage:bgImage];
        bgView.frame = CGRectMake(0, 0, imSize.width,  imSize.height);
        [self addSubview:bgView];
        
        contentView = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_MARGIN, CONTENT_MARGIN_TOP+50, imSize.width-2*CONTENT_MARGIN,  imSize.height-CONTENT_MARGIN)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        contentView.font = [UIFont systemFontOfSize:18];
        contentView.text = message;
        contentView.numberOfLines = 2;
        contentView.textAlignment = NSTextAlignmentCenter;
        contentView.layer.cornerRadius = 8;
        contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        contentView.layer.borderWidth = 1;
        
        [self addSubview:contentView];
    }
    return self;
}


- (void) layoutSubviews
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	CGSize imSize = (initType ==IMAGE_TYPE)?(imageView.frame.size):(bgView.frame.size);
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            self.frame = CGRectMake(window.center.x-imSize.width/2, window.center.y-imSize.height/2, imSize.width, imSize.height);
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            self.frame = CGRectMake(window.center.y-imSize.width/2, window.center.x-imSize.height/2, imSize.width, imSize.height);
            break;
        }
        default:
            break;
    }
    [super layoutSubviews];
}

- (void) hide
{
    self.alpha = 0.9f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:(float)DISMISS_DURATION/1000];
	self.alpha = 0.0f;
    [UIView commitAnimations];
    [self performSelector:@selector(removeMySelf) withObject:nil afterDelay:(float)DISMISS_DURATION/1000];
}

- (void) removeMySelf
{
	[self removeFromSuperview];
}

- (void) setShowDefaultAnimation
{
    self.alpha = 0.1f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:(float)DISMISS_DURATION/1000];
    self.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void) show
{
    [self show:DEFAULT_DURATION];
}

- (void) show:(NSInteger)duration
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];

    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0){
		UIView *subView = [windowViews objectAtIndex:0];
		for(UIView *aSubView in subView.subviews) {
			[aSubView.layer removeAllAnimations];
			[ToastView cancelPreviousPerformRequestsWithTarget:self];
			if([aSubView isKindOfClass:[ToastView class]]) {
				ToastView* tasotView = (ToastView*)aSubView;
				[tasotView removeMySelf];
			}
		}
        [[windowViews objectAtIndex:0] addSubview:self];
        if(duration > 0)
            [self performSelector:@selector(hide) withObject:nil afterDelay:(float)duration/1000];
    }
}

@end
