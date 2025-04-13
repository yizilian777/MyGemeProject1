extends Node2D

@export var slime_scene : PackedScene
@export var spawn_timer : Timer

@export var dino_scene : PackedScene
@export var dino_timer : Timer


@export var score : int = 0
@export var score_label : Label
@export var game_over_label: Label
@export var player: Node
@export var level_up_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#dino生成开始
	await get_tree().create_timer(7).timeout
	dino_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_timer.wait_time -= 0.2 * delta
	spawn_timer.wait_time = clamp(spawn_timer.wait_time, 0.5, 3)

	score_label.text = "Score: " + str(score)

func _spawn_slime() -> void:
	var slime_node =slime_scene.instantiate()
	slime_node.position = Vector2(260, randf_range(50, 120))
	
	slime_node.player = player
	
	get_tree().current_scene.add_child(slime_node)
 

func _spawn_dino() -> void:
	var dino_node =dino_scene.instantiate()
	dino_node.position = Vector2(260, randf_range(50, 120))
	
	dino_node.player = player
	
	get_tree().current_scene.add_child(dino_node)
 
	
func show_game_over():
	game_over_label.visible = true


func show_level_up():
	level_up_label.visible = true
	get_node("level up/LevelUpAnim").play("show_level_up")
