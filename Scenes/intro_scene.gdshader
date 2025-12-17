shader_type canvas_item;

// 这是一个参数，0.0代表全黑，1.0代表全显示
// 我们稍后会用 GDScript 代码来控制这个数字，让它慢慢变大
uniform float radius : hint_range(0.0, 1.5) = 0.0;

// 羽化程度，让边缘看起来像水墨晕开，而不是硬切
uniform float feather : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	// 获取当前背景图的颜色
	vec4 color = texture(TEXTURE, UV);
	
	// 计算当前像素点距离图片中心(0.5, 0.5)有多远
	float dist = distance(UV, vec2(0.5, 0.5));
	
	// 魔法计算：smoothstep用于生成平滑的边缘
	// 如果距离小于半径，alpha为1（显示）；如果大于半径，alpha为0（透明）
	float alpha = 1.0 - smoothstep(radius, radius + feather, dist);
	
	// 应用透明度
	color.a *= alpha;
	COLOR = color;
}