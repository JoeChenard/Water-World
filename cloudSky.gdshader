shader_type sky;

uniform sampler2D clouds : filter_nearest,repeat_enable;
uniform sampler2D grad : filter_nearest,repeat_enable;
uniform sampler2D stars : filter_nearest,repeat_enable;
uniform sampler2D cloud : filter_nearest,repeat_enable;
uniform sampler2D cloudGrad : filter_nearest,repeat_enable;
uniform vec3 color: source_color = vec3(0.1, 0.5, 1.0);

uniform float brightness = 1.5;
uniform float timeOfDay = 0.9;

void sky() {

        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
//		vec2 scroud = vec2(SKY_COORDS.x*TIME*.01,SKY_COORDS.y*TIME*.01);
		vec4 tex = texture(clouds, SKY_COORDS)*texture(grad, SKY_COORDS);
//        COLOR = vec3(0.1, 0.5, 1.0);
		COLOR = color;
		COLOR = mix(COLOR, tex.rgb, 0.6)*brightness;
//		COLOR = mix(COLOR, texture(stars, SKY_COORDS).rgb, .45*(1.0+sin(TIME/2.0)));
		COLOR = mix(COLOR, texture(stars, SKY_COORDS).rgb, .83*tanh(3.0*sin(1.0))+.05);//TIME/75.0
		
		vec3 rainClouds = texture(cloudGrad, SKY_COORDS).rgb *
							texture(cloud, SKY_COORDS).rgb +
							texture(cloudGrad, SKY_COORDS).rgb;
//		rainClouds -= .1;
		
		COLOR = mix(COLOR, rainClouds, 0.5);
		COLOR += vec3(clamp((1.0-sign(mod(TIME, 10.0)-.4))*(tanh(222.0*sin(50.0*TIME))+1.0),0.0,.5));
		
		
//		vec3 galtex = (SKY_COORDS) ? texture(galaxy, SKY_COORDS).rgb : 0.0;
//		COLOR = COLOR+galtex;
    
}