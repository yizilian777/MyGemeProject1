extends Area2D

@export var speed: float = -50
@export var health: int = 1
@export var player : Node

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
		health -= 1
		if health <= 0:
			die()

#怪物碰撞
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_dead:
		body.game_over()

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
