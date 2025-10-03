extends CharacterBody2D


@export var speed = 100.0
@export var jump_speed = -200.0
@export var gravity = 800.0


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	move_and_slide()
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_speed
