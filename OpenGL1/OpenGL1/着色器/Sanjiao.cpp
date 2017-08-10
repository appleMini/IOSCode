//
//  Sanjiao.c
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#include "Sanjiao.hpp"
#include <iostream>
#include <GL/glew.h>
#include <GLFW/glfw3.h>

void graph::Sanjiao::bindVAO() {
    this->shader = new Shader::Shader("/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/Sanjiao.vs", "/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/Sanjiao.frag");
    
    float vertices[] = {
        -0.5f, -0.5f, 0.0f, // left
        0.5f, -0.5f, 0.0f, // right
        0.0f,  0.5f, 0.0f  // top
    };
    
    glGenVertexArrays(1, &this->VAO);
    glGenBuffers(1, &this->VBO);
    
    glBindVertexArray(this->VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, this->VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    
    glEnableVertexAttribArray(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void graph::Sanjiao::display() {
    
    if (this->shader != NULL) {
        this->shader->Use();
        glBindVertexArray(this->VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
}
