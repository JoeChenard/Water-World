shader_type canvas_item;

void fragment(){//canvasitem implementation
	float glow = 1.5;
    float ledSize = 300.0;//controls size of LEDs, 
                      //larger value = smaller LEDs 
	COLOR.a = .1*cos(UV.x*ledSize)*cos(UV.y*ledSize); //sin wave - glow
    COLOR.a += ((1.0 < atan(200.0*sin(ledSize*UV.x))) && //square wave - pixel
              (1.0 < atan(200.0*sin(ledSize*UV.y)))) 
              ? 0.1 : 0.0; 
	COLOR.a *= 5.5; //brightness
}
