extends Area2D

@export var speed: float = -50
@export var health: int = 1
@export var player : Node

@onready var hurt_sound: AudioStreamPlayer = $hurt  # 场景里的播放器

@export var default_hurt_sound: AudioStream# 音频资源（拖入 .ogg）
@export var fireball_hurt_sound: AudioStream 


var is_dead = false

#移动
func _process(delta):
	if not is_dead:
		position += Vector2(speed, 0) * delta
	if position.x < -300:
		queue_free()


#子弹碰撞
func _on_area_entered(area: Area2D) -> void:
	if is_dead:
		return
	if area.is_in_group("bullet"):
		area.queue_free()
		
		var sound_type = "normal"

		hurt_sound.play()
		#health -= 1
		var damage
		damage = area.attack  # ✅ 直接访问变量，不调用函数
		take_damage(damage)
		$hurt.play()
		flash_red()
		knockback(area.knockback_strength)  # 击退
		if health <= 0:
			die()

#爆炸伤害
func take_damage(amount: int, source: String = ""):
	health -= amount
	hurt_sound.play()
	flash_red()
	if health <= 0:
		die()
	else:
		knockback(5)

#怪物碰撞
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_dead:
		body.take_damage(1)

#受击
func knockback(strength: float = 30.0):
	position += Vector2(strength, 0)

func flash_red():
	$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2)  # 红色调
	await get_tree().create_timer(0.1).timeout       # 等 0.1 秒
	$AnimatedSprite2D.modulate = Color(1, 1, 1)       # 恢复原色



#死亡
func die():
	is_dead = true
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("death")
	if has_node("deathsound"):
		$deathsound.play()
	if player:
		player.on_enemy_killed()
	await get_tree().create_timer(0.6).timeout
	queue_free()
