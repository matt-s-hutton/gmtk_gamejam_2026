extends CharacterBody3D
class_name Player

@export var max_speed := 8.0


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var dir := Vector3(input.x, 0.0, input.y)
	velocity.x = dir.x * max_speed
	velocity.z = dir.z * max_speed
	move_and_slide()
