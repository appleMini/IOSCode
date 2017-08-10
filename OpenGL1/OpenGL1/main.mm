//
//  main.m
//  OpenGL1
//
//  Created by 小布丁 on 2017/4/5.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HelloWindow.h"
#import "DisplayTest.h"
#import "NewWindow.hpp"
#import "Sanjiao.hpp"
#import "Rectangle.hpp"
#import "AttributPoints.hpp"

#ifdef __cplusplus
extern "C" {
#endif
    

    
#ifdef __cplusplus
};
#endif

using namespace graph;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        NSLog(@"Hello, World!");
//        setupConfig();
//        __main();
//        main2();
        
        
//        display_main();
//        Sanjiao sanjiao = Sanjiao();
        
//        Rectangle rect = Rectangle();
        AttributPoints att = AttributPoints();
        
        Window window = Window(&att);
        window.showWindow();
        
    }
    return 0;
}
