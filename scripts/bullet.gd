extends Area2D

var attack = 1  # ⬅️ 接收来自玩家的攻击力
@export var bullet_speed :float = 300 
var knockback_strength: float = 5.0

@export var damage_source: String = "normal"  # 或 "fireball"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().paused:
		return
	await get_tree().create_timer(3).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.

#子弹发射速度
func _process(delta: float) -> void:
	position += Vector2(bullet_speed, 0) * delta
