//
//  NSObject+KVO.h
//  Study01
//
//  Created by 小布丁 on 2017/5/12.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PGObservingBlock)(id observedObject, NSString *observedKey,  id oldValue, id newValue);

@interface NSObject(KVO)

- (void)PG_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(PGObservingBlock)block;

- (void)PG_removeObserver:(NSObject *)observer forKey:(NSString *)key;
@end
