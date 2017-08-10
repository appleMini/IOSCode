//
//  rect.frag
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/1.
//  Copyright © 2017年 小布丁. All rights reserved.
//
#version 330 core

out vec4 FragColor;

uniform vec4 ourColor;

void main() {
    FragColor = ourColor;
}
