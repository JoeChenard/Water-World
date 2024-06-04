shader_type spatial;

//render_mode blend_mix,depth_draw_always,cull_disabled,diffuse_burley,specular_schlick_ggx,world_vertex_coords;
//old ripple
//uniform vec4 water_color : source_color;
//uniform vec4 ring_color : source_color;
//uniform float ring_width : hint_range(0.0, 1.0) = 0.1;
//uniform float fadeout : hint_range(0.0, 1.0) = 0.2;
//uniform sampler2D pattern;

group_uniforms Refraction;
uniform sampler2D texture_refraction;
uniform float refraction : hint_range(-2,2);
uniform vec4 refraction_texture_channel;
uniform float refraction_opacity : hint_range(0.0, 1.0);
group_uniforms;

varying vec3	refraction_uv_tri;
varying vec3	uv_power_normal;

uniform sampler2D foamy: hint_normal;

//edge
uniform float edge_scale = .1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color: source_color;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

//new ripple
uniform float MAX_RADIUS = 2.0;
uniform float HASHSCALE1 = 0.1031;
uniform vec3 HASHSCALE3 = vec3(0.1031, 0.1030, 0.0973);
uniform sampler2D backgroundTexture;


uniform float waveSpeed = .5;
uniform float waveHeight = .5;


uniform sampler2D waterSeed: repeat_enable;
uniform sampler2D waterSeed2: repeat_enable;
uniform sampler2D waterSeed3: repeat_enable;

uniform sampler2D testTex: repeat_enable;
uniform float wave = 0.0;
uniform vec3 color: source_color;
uniform vec3 fresColor: source_color;
uniform float k: hint_range(-100.0, 100.0, 0.01) = 1.0;
uniform float w: hint_range(-100.0, 100.0, 0.01) = 1.0;

uniform float rough: hint_range(-100.0, 100.0, 0.01) = 1.0;
uniform float metal: hint_range(-100.0, 100.0, 0.01) = 1.0;

varying float height;
varying float foam;

void vertex(){
	float tim = TIME/150.0;
//	VERTEX.y = VERTEX.x*cos(TIME) + VERTEX.z*sin(TIME);
//	VERTEX.y = wave*cos(k*VERTEX.x-w*TIME)*sin(k*VERTEX.z-w*TIME);

//	float wave1 = exp(sin(20.0*texture(waterSeed,vec2(UV.x + tim*1.8, UV.y + tim*0.2)).r) - 1.0);
//	float wave2 = exp(cos(10.0*texture(waterSeed,vec2(UV.x - tim*0.3, UV.y + tim*0.2)).r) - 1.0);
//	float wave3 = -exp(sin(5.0*texture(waterSeed,vec2(UV.x + tim*0.2, UV.y - tim*0.1)).r) - 1.0);

	float wave1 = exp(sin(20.0*texture(waterSeed,vec2(UV.x + tim*1.8, UV.y + tim*0.2)).r) - 1.0);
	float wave2 = exp(cos(10.0*texture(waterSeed,vec2(UV.x - tim*0.3, UV.y + tim*0.2)).r) - 1.0);
	float wave3 = exp(sin(5.0*texture(waterSeed,vec2(UV.x + tim*0.2, UV.y - tim*0.1)).r) - 1.0);



//	wave1 = 1.0;
	
	vec3 vert = VERTEX;
	vert.y = wave1+wave2+wave3; //vec2(UV.x + TIME*0.6, UV.y)
	NORMAL = 0.9*vert;
	height = vert.y;
	
	vert.y += waveHeight*(vert.x*cos(waveSpeed*TIME) + vert.z*sin(waveSpeed*TIME))/100.0;

	foam = abs(vert.y - VERTEX.y);
	VERTEX = vert;
}

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float edge(float depth){
	depth = 2.0*depth-1.0;
	return near * far / (far + depth * (near - far));
}


float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
	p3 += dot(p3, p3.yzx + 19.19);
	return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
	p3 += dot(p3, p3.yzx+19.19);
	return fract((p3.xx+p3.yz)*p3.zy);
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	// Place fragment code here.
//	float fres = fresnel(5.0, NORMAL, VIEW);
//	ALBEDO = mix(fresColor, color, fres);
	ALBEDO = color;
//	ALBEDO = (height > 1.02) ? vec3(0.7) : ALBEDO;

//	ALBEDO += (height > .65 && height < .75) ? 
//			vec3(texture(foamy, UV).g) : 
//			ALBEDO;
//	ALBEDO = ((height > .55 && height <= .65)|| 
//			(height > .75 && height < .8)) ? 
//			vec3(texture(foamy, UV).g)-.1 : 
//			ALBEDO;
	float hDif = abs(height - 2.2);
	float hTol = .1;
	ALBEDO = (hDif < hTol) ?
			mix(ALBEDO, vec3(texture(foamy, UV).g),(hTol-hDif)/hTol + .1): 
			ALBEDO;
	
	//27405c, nice water color
	
	ALBEDO = ALBEDO*height*1.1;
	ALBEDO.b += .09;
	ALBEDO.r -= 0.03;

//	ALBEDO = (height < .03) ? ALBEDO*0.4 : ALBEDO;
//	ALBEDO *= height;


//	ALBEDO = texture(testTex,UV).rgb;
//	NORMAL_MAP = texture(norma, UV).rgb;
	ROUGHNESS = rough;
	SPECULAR = metal;
	
	
	SSS_STRENGTH = 0.5;
	
	
	//old ripple
//	vec2 pat = texture(pattern, UV*100.0).rg;
//	float grad = pat.r;
//	float fct_time = fract(TIME/10.0 + pat.g);
//	float fade = (1.0 - fct_time / fadeout);
//	grad -= fct_time;
//	grad /= ring_width;
//	grad = clamp(grad, 0.0, 1.0);
//	float ring = smoothstep(0.0, 1.0, min(grad, (1.0 - grad)) * 2.0);
//	ring *= fade;
//	ring = clamp(ring, 0.0, 1.0);
//	ALBEDO += mix(water_color, ring_color, ring).rgb;
	
	//new ripples
	float resolution = 1080.0;
	vec2 uv = UV*500.0;
	vec2 p0 = floor(uv);

	vec2 circles = vec2(0.0);
	for (float j = -MAX_RADIUS; j <= MAX_RADIUS; ++j)
	{
		for (float i = -MAX_RADIUS; i <= MAX_RADIUS; ++i)
		{
			vec2 pi = p0 + vec2(i, j);
			
			vec2 hsh = hash22(pi);
			
			vec2 p = pi + hash22(hsh);
			
			float t = fract(0.3 * TIME + hash12(hsh));
			vec2 v = p - uv;
			float d = length(v) - (float(MAX_RADIUS) + 1.)*t;
			
			float h = 1e-3;
			float d1 = d - h;
			float d2 = d + h;
			float p1 = sin(31.*d1) * smoothstep(-0.6, -0.3, d1) * smoothstep(0., -0.3, d1);
			float p2 = sin(31.*d2) * smoothstep(-0.6, -0.3, d2) * smoothstep(0., -0.3, d2);
			circles += 0.5 * normalize(v) * ((p2 - p1) / (2. * h) * (1. - t) * (1. - t));
		}
	}
	
	circles /= float(pow((MAX_RADIUS * 2.0 + 1.0),2));
	
	float intensity = mix(0.01, 0.15, smoothstep(0.1, 0.6, abs(fract(0.05 * TIME + 0.5) * 2.0 -1.0)));
	vec3 n = vec3(circles, sqrt(1.0 - dot(circles, circles)));
	vec3 Rcolor = texture(backgroundTexture, uv/resolution - intensity * n.xy).rgb + 5.0 * pow(clamp(dot(n, normalize(vec3(1.0, 0.7, 0.5))), 0.0, 1.0), 6.0);
	ALBEDO *= vec4(Rcolor, 1.0).rgb;
	
	//edge
	float z_depth = edge(texture(DEPTH_TEXTURE,SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	vec3 depth_color = mix(edge_color, color, step(edge_scale, z_dif));
	ALBEDO = clamp(ALBEDO + depth_color, vec3(0.0), vec3(1.0));
//	ALPHA = .1;

	vec2 screen_uv = SCREEN_UV;

	vec4 ref_tex;
//	ref_tex = triplanar_texture(texture_refraction, uv_power_normal, refraction_uv_tri);
}
