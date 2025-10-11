shader_type canvas_item;
uniform sampler2D Dtexture;
uniform float val: hint_range(0.0, 1.0);
uniform vec4 color = vec4(1.0,1.0,1.0,1.0);
void fragment(){
	vec4 main_texture = texture(TEXTURE,UV);
	vec4 disTexture = texture(Dtexture, UV);
	main_texture.a *= floor(val + min(disTexture.x,1));

	COLOR = main_texture * color;
}
