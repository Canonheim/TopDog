// THE STAR WIPE (Parker 11-20): black everywhere outside a five-pointed star centred on the screen.
// `open` 0 = closed (all black), 1 = open (the star past every corner). main.gd tweens it.
shader_type canvas_item;

uniform float open = 1.0;
uniform float aspect = 1.7778;  // the window's width over its height
uniform float spin = 0.0;       // radians the star is turned

// A five-pointed star's signed distance (negative inside): r its outer radius, rf how deep its notches go.
float sd_star5(vec2 p, float r, float rf) {
	const vec2 k1 = vec2(0.809016994375, -0.587785252292);
	const vec2 k2 = vec2(-k1.x, k1.y);
	p.x = abs(p.x);
	p -= 2.0 * max(dot(k1, p), 0.0) * k1;
	p -= 2.0 * max(dot(k2, p), 0.0) * k2;
	p.x = abs(p.x);
	p.y -= r;
	vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.0, 1.0);
	float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
	return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

void fragment() {
	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0);
	p.y = -p.y;  // (screen y runs down: a point up)
	float c = cos(spin);
	float s = sin(spin);
	p = vec2(c * p.x - s * p.y, s * p.x + c * p.y);
	// The star's outer radius in screen heights. Its notches sit at half its radius (rf 0.5), so at open 1
	// they just clear this window's corners: the whole wipe is seen, none of it spent off screen.
	float r_open = length(vec2(aspect * 0.5, 0.5)) / 0.5 * 1.04;
	float r = clamp(open, 0.0, 1.0) * r_open;
	float d = sd_star5(p, max(r, 0.0001), 0.5);
	float edge = 1.5 / 1080.0;  // a pixel or so of soft edge
	float a = r < 0.002 ? 1.0 : smoothstep(-edge, edge, d);
	COLOR = vec4(0.0, 0.0, 0.0, a);
}
