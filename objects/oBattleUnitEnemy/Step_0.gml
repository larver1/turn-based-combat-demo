event_inherited();

// When dead, apply effect
if (hp <= 0) {
	image_blend = c_red;
	image_alpha -= 0.01;
}