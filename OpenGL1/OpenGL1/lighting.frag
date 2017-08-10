#version 330 core
out vec4 color;

uniform vec3 objectColor;
uniform vec3 lightColor;
uniform vec3 viewPos;
uniform vec3 lightPos;

in vec3 Normal;
in vec3 FragPos;

void main()
{
    //光的颜色乘以一个(数值)很小常量环境因子，再乘以物体的颜色，然后使用它作为片段的颜色：
//    color = vec4(lightColor * objectColor, 1.0f);
//    float ambientStrength = 0.1f;
//    vec3 ambient = ambientStrength * lightColor;
//    vec3 result = ambient * objectColor;
//    color = vec4(result, 1.0f);
    
//    // Ambient
//    float ambientStrength = 0.1f;
//    vec3 ambient = ambientStrength * lightColor;
//
//    // Diffuse
//    vec3 norm = normalize(Normal);
//    vec3 lightDir = normalize(lightPos - FragPos);
//    float diff = max(dot(norm, lightDir), 0.0);
//    vec3 diffuse = diff * lightColor;
//    
//    vec3 result = (ambient + diffuse) * objectColor;
//    color = vec4(result, 1.0f);
    
    // Ambient
    float ambientStrength = 0.1f;
    vec3 ambient = ambientStrength * lightColor;
    
    // Diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;
    
    // Specular
    float specularStrength = 0.5f;
    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = specularStrength * spec * lightColor;
    
    vec3 result = (ambient + diffuse + specular) * objectColor;
    color = vec4(result, 1.0f);
}
