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

@export var score : int = 0
@export var score_label : Label
@export var game_over_label: Label
@export var player: Node
@export var level_up_label : Label

var upgrades = [
	{ "name": "攻击力+", "effect": func(): player.attack += 1 },
	{ "name": "移动速度+", "effect": func(): player.move_speed += 5},
	{ "name": "HP+", "effect": func(): player.hp += 2 },
	{ "name": "攻击速度+", "effect": func(): player.shoot_timer.wait_time *= 0.8 },
	{ "name": "暴击率+", "effect": func(): player.crit_rate += 0.1 },
	{ "name": "爆炸范围+", "effect": func(): player.fireball_explosion_radius += 5 },
	{ "name": "击退+", "effect": func(): player.knockback_strength += 5 },
]

var selected_effects = []
var original_button_positions: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_screen_mask()
	await get_tree().process_frame
	var buttons = [
		$CanvasLayer/LevelUpPanel/Button,
		$CanvasLayer/LevelUpPanel/Button2,
		$CanvasLayer/LevelUpPanel/Button3
	]

	for button in buttons:
		original_button_positions.append(button.position)
	#怪物生成开始时间
	await get_tree().create_timer(5).timeout
	dino_timer.start()
	
	await get_tree().create_timer(5).timeout
	dog_timer.start()
	
	await get_tree().create_timer(5).timeout
	skeleton_timer.start()
	
	await get_tree().create_timer(5).timeout
	frog_timer.start()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:#每帧运行
	#怪物生成间隔
	if get_tree().paused:#如果暂停则不运行
		return
	slime_timer.wait_time -= 0.1 * delta
	slime_timer.wait_time = clamp(slime_timer.wait_time, 0.3, 3)

	score_label.text = "Score: " + str(score)


#生成怪物
func _spawn_enemy(enemy_scene: PackedScene) -> void:
	if get_tree().paused:
		return
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(260, randf_range(45, 135))
	enemy.player = player
	add_child(enemy)

func _spawn_slime() -> void:
	_spawn_enemy(slime_scene)

func _spawn_dino() -> void:
	_spawn_enemy(dino_scene)
	
func _spawn_dog() -> void:
	_spawn_enemy(dog_scene)
	
func _spawn_skeleton() -> void:
	_spawn_enemy(skeleton_scene)

func _spawn_frog() -> void:
	_spawn_enemy(frog_scene)
	
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
		
		# 🔽 添加上下浮动的 tween（循环）
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
		
