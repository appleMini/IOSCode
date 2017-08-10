//
//  CTView.m
//  Study01
//
//  Created by 小布丁 on 2017/7/3.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "CTView.h"

@implementation CTView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //flip the coordinate system
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height-64));
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"你好，谢谢！"];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attrStr
                                                                         .length), path, NULL);
    
    
    CTFrameDraw(frame, ctx);
    
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frame);
}

@end
