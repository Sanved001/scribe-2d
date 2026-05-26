shader_type canvas_item;
uniform bool Flash_White = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 current_color = texture(TEXTURE, UV);
	if (Flash_White){
	COLOR = vec4(1.0, 1.0, 1.0, current_color.a);
	};
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
