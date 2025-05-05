shader_type canvas_item;

uniform float blur_radius = 2;
uniform int blur_strength = 3;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 sum = vec4(0.0);
    vec2 size = blur_radius / vec2(textureSize(TEXTURE, 0));

    for (int x = -blur_strength; x <= blur_strength; x++) {
        for (int y = -blur_strength; y <= blur_strength; y++) {
            sum += texture(TEXTURE, UV + vec2(float(x), float(y)) * size);
        }
    }
    COLOR = sum / pow(float(blur_strength) * 2.0 + 1.0, 2.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
