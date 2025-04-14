extends Node2D

@export var slime_scene : PackedScene
@export var slime_timer : Timer

@export var dino_scene : PackedScene
@export var dino_timer : Timer

@export var dog_scene: PackedScene
@export var dog_timer : Timer

@export var score : int = 0
@export var score_label : Label
@export var game_over_label: Label
@export var player: Node
@export var level_up_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#怪物生成开始时间
	await get_tree().create_timer(1).timeout
	dino_timer.start()
	
	await get_tree().create_timer(2).timeout
	dog_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#怪物生成间隔
	slime_timer.wait_time -= 0.2 * delta
	slime_timer.wait_time = clamp(slime_timer.wait_time, 0.5, 3)

	score_label.text = "Score: " + str(score)


#生成怪物
func _spawn_enemy(enemy_scene: PackedScene) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(260, randf_range(50, 120))
	enemy.player = player
	add_child(enemy)

func _spawn_slime() -> void:
	_spawn_enemy(slime_scene)

func _spawn_dino() -> void:
	_spawn_enemy(dino_scene)
	
func _spawn_dog() -> void:
	_spawn_enemy(dog_scene)
	
func show_game_over():
	game_over_label.visible = true


func show_level_up():
	level_up_label.visible = true
	get_node("level up/LevelUpAnim").play("show_level_up")
