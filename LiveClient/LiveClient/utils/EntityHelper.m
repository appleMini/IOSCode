//
//  EntityHelper.m
//  LiveClient
//  使用前提条件是：字典的Key和实体对象属性的单词是一样的，大小可以忽略。
//  Created by 小布丁 on 2017/3/10.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import "EntityHelper.h"
#import <objc/runtime.h>  

@implementation EntityHelper
#pragma mark - Custom Method

+ (void) dictionaryToEntity:(NSDictionary *)dict entity:(NSObject*)entity
{
    if (dict && entity) {
        
        for (NSString *keyName in [dict allKeys]) {
            //构建出属性的set方法
            NSString *destMethodName = [NSString stringWithFormat:@"set%@:",[keyName capitalizedString]]; //capitalizedString返回每个单词首字母大写的字符串（每个单词的其余字母转换为小写）
            SEL destMethodSelector = NSSelectorFromString(destMethodName);
            
            if ([entity respondsToSelector:destMethodSelector]) {
                
                [entity performSelector:destMethodSelector withObject:[dict objectForKey:keyName]];
            }
            
        }//end for
        
    }//end if
}

+ (NSDictionary *) entityToDictionary:(id)entity
{
    
    Class clazz = [entity class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
        //        const char* attributeName = property_getAttributes(prop);
        //        NSLog(@"%@",[NSString stringWithUTF8String:propertyName]);
        //        NSLog(@"%@",[NSString stringWithUTF8String:attributeName]);
        
        id value =  [entity performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
        if(value ==nil)
            [valueArray addObject:[NSNull null]];
        else {
            [valueArray addObject:value];
        }
        //        NSLog(@"%@",value);
    }
    
    free(properties);
    
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    NSLog(@"%@", returnDic);
    
    return returnDic;
}

@end
