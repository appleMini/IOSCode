//
//  Person.h
//  Study01
//
//  Created by 小布丁 on 2017/7/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject {
    NSString *_fullname;
    NSString *testStr;
}

@property (nonatomic, copy) NSString *fullname;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int age;

+ (instancetype)sharePerson;
- (void)show;
@end
