//
//  attributs.vs
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/4.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 ourColor;

void main() {
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor;
}
