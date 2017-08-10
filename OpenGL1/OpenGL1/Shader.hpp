//
//  Shader.hpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/4/7.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef Shader_hpp
#define Shader_hpp

#include <stdio.h>
#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <GL/glew.h>  // 包含glew来获取所有的必须OpenGL头文件

class Shader {

public:
    // 程序ID
    GLuint Program;
    // 构造器读取并构建着色器
    Shader(const GLchar* vertexPath, const GLchar* fragmentPath);
    // 使用程序
    void Use();
};

#endif /* Shader_hpp */
