//
//  EntityHelper.h
//  LiveClient
//
//  Created by 小布丁 on 2017/3/10.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntityHelper : NSObject
//字典对象转为实体对象
+ (void) dictionaryToEntity:(NSDictionary *)dict entity:(NSObject*)entity;

//实体对象转为字典对象
+ (NSDictionary *) entityToDictionary:(id)entity;
@end
