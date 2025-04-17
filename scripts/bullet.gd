extends Area2D

@export var bullet_speed :float = 100 
@export var knockback_strength: float = 5.0

@export var damage_source: String = "normal"  # 或 "fireball"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.

#子弹发射速度
func _process(delta: float) -> void:
	position += Vector2(bullet_speed, 0) * delta
