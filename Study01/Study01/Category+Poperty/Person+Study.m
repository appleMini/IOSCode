//
//  Person+Study.m
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "Person+Study.h"
#import <objc/runtime.h>

static const void *scoreKey = &scoreKey;
static const void *schoolKey = &schoolKey;

@implementation Person(Study)

+ (void)load {
    NSLog(@"load====StudyStudyStudyStudy");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(show);
        SEL swizzledSelector = @selector(print);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
    
}

- (void)setScore:(int)score {
    NSNumber *number = [NSNumber numberWithInt:score];
    objc_setAssociatedObject(self, scoreKey, number, OBJC_ASSOCIATION_ASSIGN);
}

- (int)score {
    return [objc_getAssociatedObject(self, scoreKey) intValue];
}

- (void)setSchool:(NSString *)school {
    objc_setAssociatedObject(self, schoolKey, school, OBJC_ASSOCIATION_COPY);
}

- (NSString *)school {
    return objc_getAssociatedObject(self, schoolKey);
}

- (void)print {
    NSLog(@"======StudyStudyStudyStudyStudy====");
}
@end
