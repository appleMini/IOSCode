//
//  NewWindow.h
//  OpenGL1
//
//  Created by 小布丁 on 2017/7/25.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef NewWindow_h
#define NewWindow_h
#include "BaseGraph.hpp"

#include <iostream>

namespace graph {
    class Window {
        
    private:
    BaseGraph *graphCtx = NULL;
        
    public:
        Window(BaseGraph *graphCtx);
        
        int showWindow();
    };
};

#endif /* NewWindow_h */
