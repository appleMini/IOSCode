//
//  AttributPoints.cpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/4.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#include "AttributPoints.hpp"

using namespace graph;

void AttributPoints::bindVAO() {
    this->shader = new Shader::Shader("/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/attributs.vs", "/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/attributs.frag");
    
    float vertices[] = {
        // 位置              // 颜色
        0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // 右下
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // 左下
        0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // 顶部
    };
    
    unsigned int VBO;
    glGenVertexArrays(1, &this->VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(this->VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)(3 *sizeof(float)));
    glEnableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    if (this->shader != NULL) {
        this->shader->Use();
    }
}

void AttributPoints::display() {
    glBindVertexArray(this->VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}
