shader_type canvas_item;
// The echo: a dark, translucent shadow of the player with glowing cyan eyes,
// a pulsing cyan outline and scanlines (glitch offsets it on spawn/finish).
uniform vec4 tint : source_color = vec4(0.133, 0.827, 0.933, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.62;
uniform float glitch : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV;
	float line = floor(FRAGCOORD.y);
	if (glitch > 0.0) {
		float j = fract(sin(line * 12.9898 + floor(TIME * 20.0)) * 43758.5453);
		uv.x += (j - 0.5) * glitch * px.x * 6.0;
	}
	vec4 c = texture(TEXTURE, uv);
	float n = texture(TEXTURE, uv + vec2(px.x, 0.0)).a + texture(TEXTURE, uv - vec2(px.x, 0.0)).a
		+ texture(TEXTURE, uv + vec2(0.0, px.y)).a + texture(TEXTURE, uv - vec2(0.0, px.y)).a;
	float scan = 0.82 + 0.18 * step(0.5, fract(line * 0.5 + TIME * 3.0));
	if (c.a > 0.5) {
		float lum = dot(c.rgb, vec3(0.3, 0.59, 0.11));
		vec3 shadow = vec3(0.04, 0.06, 0.12);
		vec3 col = mix(shadow, mix(tint.rgb, vec3(1.0), 0.4), step(0.5, lum));  // eyes glow
		COLOR = vec4(col, alpha * scan);
	} else if (n > 0.0) {
		COLOR = vec4(tint.rgb, alpha * 0.8 * (0.75 + 0.25 * sin(TIME * 6.0)));
	} else {
		COLOR = vec4(0.0);
	}
}
