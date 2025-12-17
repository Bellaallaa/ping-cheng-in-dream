shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    // 计算灰度值 (去色)
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    // 把原来的颜色替换成灰色
    COLOR = vec4(gray, gray, gray, color.a);
}