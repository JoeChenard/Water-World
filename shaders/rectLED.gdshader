shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){//canvasitem implementation
	vec4 tex = texture(SCREEN_TEXTURE,SCREEN_UV);
	float glow = 1.5;
    float ledSize = 500.0;//controls size of LEDs, 
                      //larger value = smaller LEDs 
	tex.a = .1*cos(UV.x*ledSize)*cos(UV.y*ledSize); //sin wave - glow
    tex.a += ((1.0 < atan(200.0*sin(ledSize*UV.x))) && //square wave - pixel
              (1.0 < atan(200.0*sin(ledSize*UV.y)))) 
              ? 0.1 : 0.0; 
	tex.a *= 5.5; //brightness
	COLOR = vec4(0.0);
	COLOR -= tex;
}