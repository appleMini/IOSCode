//
//  AttributPoints.hpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/4.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef AttributPoints_hpp
#define AttributPoints_hpp

#include <stdio.h>
#include "BaseGraph.hpp"

namespace graph {
    class AttributPoints : public BaseGraph {
    public:
        void bindVAO();
        void display();
    };
};

#endif /* AttributPoints_hpp */
