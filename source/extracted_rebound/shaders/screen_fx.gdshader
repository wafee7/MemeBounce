shader_type canvas_item;
// Post effect: vignette, faint scanlines and an on-demand glitch (slice shift + RGB split).
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float glitch : hint_range(0.0, 1.0) = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float hash(float n) { return fract(sin(n) * 43758.5453); }

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = SCREEN_PIXEL_SIZE;
	float row = floor(FRAGCOORD.y / 3.0);
	float t = floor(TIME * 24.0);
	if (glitch > 0.0) {
		float h = hash(row * 7.13 + t);
		if (h < glitch * 0.6) {
			uv.x += (hash(row + t * 3.1) - 0.5) * 24.0 * px.x * glitch;
		}
	}
	vec3 c;
	float split = glitch * 2.0 * px.x;
	c.r = texture(screen_tex, uv + vec2(split, 0.0)).r;
	c.g = texture(screen_tex, uv).g;
	c.b = texture(screen_tex, uv - vec2(split, 0.0)).b;
	float scan = 1.0 - 0.06 * step(0.5, fract(FRAGCOORD.y * 0.5));
	vec2 d = SCREEN_UV - 0.5;
	float vig = 1.0 - smoothstep(0.35, 0.85, length(d * vec2(1.2, 1.0)));
	c *= scan * mix(0.55, 1.0, vig);
	c = mix(c, flash_color.rgb, flash);
	COLOR = vec4(c, 1.0);
}
