//
//  attributs.frag
//  OpenGL1
//
//  Created by 小布丁 on 2017/8/4.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#version 330 core
out vec4 FragColor;
in vec3 ourColor;

void main() {
    FragColor = vec4(ourColor, 1.0f);
}
