shader_type canvas_item;
// Sprite flash (damage / respawn) by mixing towards a solid colour.
// base_tint recolours the sprite itself (black = silhouette) without
// dimming the flash. outline_color (alpha > 0 turns it on) draws a 1 px
// outline around the sprite, sampling only inside the current frame of the
// sheet (frame_size, in pixels) so neighbouring frames never bleed in.
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0);
uniform vec4 base_tint : source_color = vec4(1.0);
uniform vec4 outline_color : source_color = vec4(0.0);
uniform vec2 frame_size = vec2(16.0, 16.0);

// The fragment's incoming COLOR already includes the texture, which would
// erase the outline (it lives on transparent pixels), so the node's
// modulate is passed through separately.
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

// 1.0 if uv lies inside the current frame of the sheet, else 0.0.
float in_frame(vec2 uv, vec2 origin, vec2 size) {
	return step(origin.x, uv.x) * step(origin.y, uv.y)
		* (1.0 - step(origin.x + size.x, uv.x)) * (1.0 - step(origin.y + size.y, uv.y));
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec4 result = vec4(mix(c.rgb * base_tint.rgb, flash_color.rgb, flash), c.a);
	if (c.a < 0.5 && outline_color.a > 0.0) {
		// (TEXTURE can't be passed into helper functions in the Compatibility renderer)
		vec2 px = TEXTURE_PIXEL_SIZE;
		vec2 fuv = frame_size * px;
		vec2 origin = floor(UV / fuv) * fuv;
		vec2 r = UV + vec2(px.x, 0.0);
		vec2 l = UV - vec2(px.x, 0.0);
		vec2 d = UV + vec2(0.0, px.y);
		vec2 u = UV - vec2(0.0, px.y);
		float n = max(max(texture(TEXTURE, r).a * in_frame(r, origin, fuv), texture(TEXTURE, l).a * in_frame(l, origin, fuv)),
				max(texture(TEXTURE, d).a * in_frame(d, origin, fuv), texture(TEXTURE, u).a * in_frame(u, origin, fuv)));
		if (n > 0.5) {
			result = vec4(mix(outline_color.rgb, flash_color.rgb, flash), outline_color.a);
		}
	}
	COLOR = result * tint;
}
