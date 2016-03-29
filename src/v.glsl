// Simple sepia shader for LÖVE
// License: CC0
// Version: 1.0
// Author:  Landon Manning
// Email:   LManning17@gmail.com

uniform int   u_color   = 0;
uniform float u_opacity = 0.75;
//extern float iGlobalTime;
uniform float iGlobalTime;


const vec3 SEPIA[2] = vec3[2](
	vec3(1.2, 1.0, 0.8),
	vec3(1.0, 0.95, 0.82)
);

vec4 effect(vec4 color, sampler2D texture, vec2 texCoords, vec2 screenCoords) {
	// vec4 texColor = texture2D(texture, texCoords);
	//
	// // NTSC weights
	// float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));
	//
	// vec3 sepia = vec3(grey);
	//
	// switch (u_color) {
	// case 0:
	// 	sepia *= SEPIA[0];
	// 	break;
	// case 1:
	// 	sepia *= SEPIA[1];
	// 	break;
	// default:
	// 	sepia *= SEPIA[0];
	// }
	//
	// texColor.rgb = mix(
	// 	texColor.rgb,
	// 	sepia,
	// 	u_opacity
	// );

	if(screenCoords.x > (love_ScreenSize.x/2)){
    //return vec4(1.0,0.0,0.0,1.0);//red
		vec4 pixel = Texel(texture, texCoords );//This is the current pixel color
  	return pixel * color;
  }else{

		vec4 pixel = Texel(texture, texCoords );//This is the current pixel color

	  // number average = (pixel.r+pixel.b+pixel.g)/3.0;
	  // pixel.r = average;
	  // pixel.g = average;
	  // pixel.b = average;

		if(pixel.g < 250){
			number average = (pixel.r+pixel.b+pixel.g)/3.0;
			pixel.r = average;
			pixel.g = average;
			pixel.b = average;
		}else{
			number average = (pixel.r+pixel.b+pixel.g)/3.0;
			pixel.r = average;
			pixel.g = average;
			pixel.b = average;
		}


		
	  return vec4(vec3(pixel.r, pixel.g, pixel.b), pixel.a);

    //return vec4(0.0,0.0,1.0,1.0);//blue
  }




	//return texColor * color;
}
