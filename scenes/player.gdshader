shader_type canvas_item;
//uniform vec3 my_colors;
uniform bool Flash_White = false;

void vertex() {
	// Called for every vertex the material is visible on.
	
  // Animate Sprite2D moving in big circle around its location
  //VERTEX += vec2(tan(TIME)*100.0, sin(TIME)*0.0);
}

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	if (Flash_White){
	COLOR = vec4(1.0, 1.0, 1.0, current_color.a);
	};
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
