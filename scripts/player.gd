extends CharacterBody2D

@export var move_speed : float = 50
@export var animator :AnimatedSprite2D


var is_game_over :bool = false

@export var bullet_scene : PackedScene

#升级
var kill_count = 0
var kills_to_level_up = 1
var player_level = 1

@export var shoot_timer: Timer




func _process(delta: float) -> void:
	if velocity == Vector2.ZERO or is_game_over:
		$runningsound.stop()
	elif not $runningsound.playing:
		$runningsound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_game_over :
		velocity = Input.get_vector("left","right","up","down") * move_speed
		
		# 待机和跑步动画
		if  velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			animator.play("run")
			
		move_and_slide()


func game_over():
	if not is_game_over:
		
		is_game_over = true
		animator.play("game_over")
		
		get_tree().current_scene.show_game_over()
		$gameoversound.play()
		
		
		$RestartTimer.start()


func _on_fire() -> void:
	if velocity != Vector2.ZERO or is_game_over:
		return
	
	$firesound.play()
	
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position + Vector2(6, 6)
	get_tree().current_scene.add_child(bullet_node)


func _reload_scene() -> void:
	get_tree().reload_current_scene()
	

func on_enemy_killed():
	kill_count += 1
	print("干掉一个，还剩：", kills_to_level_up - kill_count , "个")
	if kill_count >= kills_to_level_up:
		level_up()

func level_up():
	var label = get_tree().current_scene.get_node("level up")
	player_level += 1
	kill_count = 0
	kills_to_level_up += 5

	
	label.position = position + Vector2(-50, -28)
	label.visible = true
	label.get_node("LevelUpAnim").play("show_level_up")
	
	shoot_timer.wait_time = shoot_timer.wait_time*0.7
	get_tree().current_scene.show_level_up()
	

	
	print("更吊了！当前等级为：", player_level)
	
	
