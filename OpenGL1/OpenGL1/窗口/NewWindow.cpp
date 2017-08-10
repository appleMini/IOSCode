//
//  NewWindow.c
//  OpenGL1
//
//  Created by 小布丁 on 2017/7/25.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#include "NewWindow.hpp"

#include <GL/glew.h>
#include <GLFW/glfw3.h>

//定义窗口大小改变的回调
void framebuffer_size_callbcak(GLFWwindow *window, GLint width, GLint height);
void processInput(GLFWwindow *window);

graph::Window::Window(graph::BaseGraph *graphCtx) {
    this->graphCtx = graphCtx;
}

//实例化GLFW 窗口
int graph::Window::showWindow() {
    glfwInit();
    //主版本号
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    //明确告诉GLFW我们需要使用核心模式意味着我们只能使用OpenGL功能的一个子集（没有我们已不再需要的向后兼容特性）
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    //Mac OS X系统，你还需要加下面这行代码到你的初始化代码中这些配置才能起作用
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    
    //创建窗口
    GLFWwindow *window = glfwCreateWindow(480, 320, "learn OpenGLES", NULL, NULL);
    
    if (window == NULL) {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    glfwMakeContextCurrent(window);
    
    //GLEW是用来管理OpenGL的函数指针的，所以在调用任何OpenGL的函数之前我们需要初始化GLEW。
    glewExperimental = GL_TRUE;
    if(glewInit() != GLEW_OK){
        std::cout << "Failed to initialize GLEW" << std::endl;
        return -1;
    }
    
    GLint width, height;
    glfwGetFramebufferSize(window, &width, &height);
    glViewport(0, 0, width, height);
    
    //注册窗口回调
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callbcak);
    
    //开启深度检测
    glEnable(GL_DEPTH_TEST);
    
    ///设置顶点
    if (this->graphCtx == NULL) {
        return -1;
    }
    
    this->graphCtx->bindVAO();
    
    //渲染循环
    while (!glfwWindowShouldClose(window)) {
        // 输入
        processInput(window);
        
        //渲染指令
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        this->graphCtx->display();
        
        //函数会交换颜色缓冲
        glfwSwapBuffers(window);
        //函数检查有没有触发什么事件（比如键盘输入、鼠标移动等）、更新窗口状态，并调用对应的回调函数（可以通过回调方法手动设置）
        glfwPollEvents();
    }
    
    glDeleteVertexArrays(1, &this->graphCtx->VAO);
    glDeleteBuffers(1, &this->graphCtx->VBO);
    glfwTerminate();
    return 0;
}

void framebuffer_size_callbcak(GLFWwindow *window, GLint width, GLint height) {
    std::cout << "窗口改变" << std::endl;
    glViewport(0, 0, width, height);
}

void processInput(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}
