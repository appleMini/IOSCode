//
//  Sanjiao.h
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef Sanjiao_h
#define Sanjiao_h

#include <stdio.h>
#include "BaseGraph.hpp"
#include "Shader.hpp"

namespace graph {

class Sanjiao : public BaseGraph {
    unsigned int VBO, VAO;
    
public:
    void bindVAO();
    void display();
};
    
};

#endif /* Sanjiao_h */
