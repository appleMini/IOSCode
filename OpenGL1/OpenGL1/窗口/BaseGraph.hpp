//
//  BaseGraph.hpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/2.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef BaseGraph_hpp
#define BaseGraph_hpp

#include <stdio.h>
#include "Shader.hpp"

namespace graph {
    
    class BaseGraph {
        
    public:
        unsigned int VAO, VBO;
        Shader *shader = NULL;
        virtual void bindVAO()=0;
        virtual void display()=0;
    };
};
#endif /* BaseGraph_hpp */
