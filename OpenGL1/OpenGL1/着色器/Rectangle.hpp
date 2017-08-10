//
//  Rect.hpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef Rect_hpp
#define Rect_hpp

#include <stdio.h>
#include "BaseGraph.hpp"

namespace graph {

class Rectangle : public BaseGraph {
    unsigned int EBO;
    
public:
    void bindVAO();
    void display();
};
    
};

#endif /* Rect_hpp */
