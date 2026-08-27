shader_type sky;

void sky() {
	float value = (sin(EYEDIR.x * 15.0 + TIME * .2) * .25 + .5) + (sin(EYEDIR.y * 5. + TIME * .5) * .25 + .5);
	vec3 col = mix(vec3(EYEDIR.y * .5 + .5, .5, EYEDIR.x * .5 + .5), vec3(.1, EYEDIR.x * .5 + .5, EYEDIR.y * .5 + .5), sin(EYEDIR.y* 20. + TIME * .5));
	COLOR = vec3(value * col);
}
