shader_type canvas_item;

uniform vec2 direction = vec2(1.0, 0.0); // Direction of scroll
uniform float speed : hint_range(0.0, 5.0) = 0.5; // Scroll speed

void vertex() {
    // Shifts the UV coordinates over time
    UV += direction * TIME * speed;
}