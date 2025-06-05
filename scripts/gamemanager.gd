extends Node2D

@export var slime_scene : PackedScene
@export var slime_timer : Timer

@export var dino_scene : PackedScene
@export var dino_timer : Timer

@export var dog_scene: PackedScene
@export var dog_timer : Timer

@export var skeleton_scene: PackedScene
@export var skeleton_timer : Timer

@export var frog_scene: PackedScene
@export var frog_timer : Timer

var enemy_scenes = []
var unlocked_count = 1
var spawn_timer = 0.0
var unlock_timer = 0.0
var spawn_interval = 3.0
var unlock_interval = 40.0
var spawn_count = 1

@export var score : int = 0
@export var score_label : Label
@export var game_over_label: Label
@export var player: Node
@export var level_up_label : Label

var upgrades = [
	{ "name": "攻撃力+", "effect": func(): player.attack += 1 },
	{ "name": "移動速度+", "effect": func(): player.move_speed += 5},
	{ "name": "HP+", "effect": func(): player.hp += 2 },
	{ "name": "攻撃速度+", "effect": func(): player.shoot_timer.wait_time *= 0.7 },
	{ "name": "会心率+", "effect": func(): player.crit_rate += 0.1 },
	{ "name": "爆発範囲+", "effect": func(): player.fireball_explosion_radius += 8 },
	{ "name": "ノックバック+", "effect": func(): player.knockback_strength += 3 },
]

var selected_effects = []
var original_button_positions: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_scenes = [
	{ "scene": slime_scene, "weight": 100 },
	{ "scene": dino_scene, "weight": 30 },
	{ "scene": dog_scene, "weight": 20 },
	{ "scene": skeleton_scene, "weight": 5 },
	{ "scene": frog_scene, "weight": 1 },
	]
	hide_screen_mask()
	await get_tree().process_frame
	var buttons = [
		$CanvasLayer/LevelUpPanel/Button,
		$CanvasLayer/LevelUpPanel/Button2,
		$CanvasLayer/LevelUpPanel/Button3
	]

	for button in buttons:
		original_button_positions.append(button.position)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:#每帧运行
	update_status_panel()
	#怪物生成间隔
	
	if get_tree().paused:#如果暂停则不运行
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_interval
		call_deferred("_spawn_multiple_enemies", spawn_count)

	unlock_timer += delta
	if unlock_timer >= unlock_interval:
		unlock_timer = 0.0
		if unlocked_count < enemy_scenes.size():
			unlocked_count += 1
		spawn_count += 5
		spawn_interval = max(0.1, spawn_interval * 0.95)



#生成怪物
func spawn_enemy():
	if get_tree().paused:
		return  # 暂停时不生成怪物
	var pool: Array = []

	# 用当前解锁数量限制敌人
	for i in range(unlocked_count):
		var item = enemy_scenes[i]
		for j in range(item["weight"]):
			pool.append(item["scene"])
			
	var scene = pool[randi() % pool.size()]
	var enemy = scene.instantiate()
	enemy.position = Vector2(260, randf_range(45, 130))
	enemy.player = player
	add_child(enemy)

func _spawn_multiple_enemies(count: int) -> void:
	for i in range(count):
		var delay = randf_range(0.0, 1.0)
		await get_tree().create_timer(delay).timeout
		spawn_enemy()
	
func show_game_over():
	game_over_label.visible = true


func show_level_up():
	if player.is_game_over:
		return 
	$"time stop".play()
	shrink_black_mask_to_circle()
	get_tree().paused = true
	
	var chosen = upgrades.duplicate()
	chosen.shuffle()
	chosen = chosen.slice(0, 3)

	var buttons = [
		$CanvasLayer/LevelUpPanel/Button,
		$CanvasLayer/LevelUpPanel/Button2,
		$CanvasLayer/LevelUpPanel/Button3
	]

	
	selected_effects.clear()
	
	for i in range(3):
		var upgrade = chosen[i]
		var button = buttons[i]
		button.text = upgrade["name"]
		
		button.position = original_button_positions[i]
		if button.pressed.is_connected(_on_upgrade_chosen):
			button.pressed.disconnect(_on_upgrade_chosen)

		selected_effects.append(upgrade["effect"])
		button.pressed.connect(_on_upgrade_chosen.bind(i))
		
		button.scale = Vector2(0.0, 0.0)  # 🔸初始缩小
		button.pivot_offset = (button.size / 2) - Vector2(-5, -5)
		
		
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(0.70, 0.70), 2)
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# 添加上下浮动的 tween（循环）
		var delay = randf_range(0.0, 0.5)
		var offset = randf_range(4.0, 8.0)  # 上下移动范围
		var speed = randf_range(0.1, 0.3)   # 移动速度

		var float_tween = create_tween()
		float_tween.set_loops()  # 无限循环
		float_tween.tween_property(button, "position:y", button.position.y - 5, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		float_tween.tween_property(button, "position:y", button.position.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


	level_up_label.visible = true
	get_node("level up/LevelUpAnim").play("show_level_up")
	$CanvasLayer/LevelUpPanel.visible = true
#选择完成
func _on_upgrade_chosen(index: int):
	$button.play()
	selected_effects[index].call()  # 执行玩家选的那个升级效果

	$CanvasLayer/LevelUpPanel.visible = false
	hide_screen_mask()
	get_tree().paused = false
	var buttons = [
		$CanvasLayer/LevelUpPanel/Button,
		$CanvasLayer/LevelUpPanel/Button2,
		$CanvasLayer/LevelUpPanel/Button3
	]	
		
	$CanvasLayer/LevelUpPanel.visible = false
	hide_screen_mask()
	get_tree().paused = false

func shrink_black_mask_to_circle():
	var mask = $CanvasLayer/ScreenMask
	mask.visible = true
	
	mask.material.set_shader_parameter("radius", 1.5)  # 一开始全透明
	

	var tween = create_tween()
	tween.tween_property(mask.material, "shader_parameter/radius", 0.0, 1.5)
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func hide_screen_mask():
	$CanvasLayer/ScreenMask.hide()
	
func update_status_panel():
	$CanvasLayer/Panel/level.text = "Level  :  " + str(player.level)
	$"CanvasLayer/Panel/level to up".text = "レベルアップまで : " + str(player.remaining)
	$CanvasLayer/Panel/AttackLabel.text = "攻撃力:  " + str(player.attack)
	$CanvasLayer/Panel/Label2.text = "HP:  " + str(player.hp)
	$CanvasLayer/Panel/Label3.text = "会心率:  " + str(round(player.crit_rate * 100)) + "%"
	$CanvasLayer/Panel/Label4.text = "攻撃間隔:  " + str(player.shoot_timer.wait_time) + "s"
	$CanvasLayer/Panel/Label5.text = "移動速度:  " + str(player.move_speed)
	$CanvasLayer/Panel/Label6.text = "爆発範囲:  " + str(player.fireball_explosion_radius)
	$CanvasLayer/Panel/Label7.text = "ノックバック:  " + str(player.knockback_strength)
