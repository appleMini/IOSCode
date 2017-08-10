//
//  Sanjiao.vs
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//
#version 330 core

layout(location = 0) in vec3 pos;

void main() {
    gl_Position = vec4(pos.x , pos.y, pos.z, 1.0f);
}
