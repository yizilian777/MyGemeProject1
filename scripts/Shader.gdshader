shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 1.5;
uniform vec2 center = vec2(0.5, 0.5);


void fragment() {
	vec2 uv = SCREEN_UV;
	float dist = distance(uv, center);

	if (dist < radius) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);  // 中心区域透明，显示画面
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.25);  // 外部黑幕盖住
	}
}


