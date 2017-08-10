//
//  Rect.cpp
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#include "Rectangle.hpp"
#include <iostream>
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <math.h>


void graph::Rectangle::bindVAO() {
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    this->shader = new Shader::Shader("/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/rect.vs", "/Users/xiaoxiao/Documents/iOS OpenGL ES 学习/OpenGL1/OpenGL1/着色器/rect.frag");
    
    //长方形
    float vertices[] = {
        -0.5f, -0.5f, 0.0f, // leftbottom
        0.5f, -0.5f, 0.0f, // rightbottom
        -0.5f,  0.5f, 0.0f,  // lefttop
        0.5f,  0.5f, 0.0f  // righttop
    };
    
    unsigned int indices[] = {
        0, 1, 3,
        2, 0, 3
    };
    
//    float vertices[] = {
//        0.5f, 0.5f, 0.0f,   // 右上角
//        0.5f, -0.5f, 0.0f,  // 右下角
//        -0.5f, -0.5f, 0.0f, // 左下角
//        -0.5f, 0.5f, 0.0f   // 左上角
//    };
//    
//    unsigned int indices[] = { // 注意索引从0开始!
//        0, 1, 3, // 第一个三角形
//        1, 2, 3  // 第二个三角形
//    };
    
    
    glGenVertexArrays(1, &this->VAO);
    glGenBuffers(1, &this->VBO);
    glGenBuffers(1, &this->EBO);
    
    glBindVertexArray(this->VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, this->VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this->EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

}

void graph::Rectangle::display() {
    
    
    float timeValue = glfwGetTime();
    float greenValue = sin(timeValue) / 2.0f + 0.5f;
    
    int vertexColorLocation = glGetUniformLocation(this->shader->Program, "ourColor");
    
    if (this->shader != NULL) {
        this->shader->Use();
        
        //// 更新uniform颜色
        glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
        
        glBindVertexArray(this->VAO);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    }
}
