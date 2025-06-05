extends Area2D #宣言

var attack = 1
@export var damage_source: String = "fireball"
@export var speed = 200  # 慢速移动
@export var explosion_scale = 5.0
@export var knockback_strength: float = 5.0


@export var initial_radius = 10.0  #  新增：初始判定范围
@export var explosion_radius = 20.0  # 爆炸时的固定判定范围


var shape: CircleShape2D
var original_radius = 0.0  # 存储初始半径
var is_exploding = false

@export var player: Node

func _process(delta):
	if is_exploding:
		return
	position += Vector2(speed, 0) * delta
	
func _ready():
	$AnimatedSprite2D.play("fly")
	shape = $CollisionShape2D.shape as CircleShape2D
	shape.radius = initial_radius
	original_radius = shape.radius
	if get_tree().paused:
		return
	await get_tree().create_timer(6).timeout
	queue_free()
	
func _on_area_entered(area: Area2D):
	if is_exploding:
		return
	
	if area.is_in_group("enemy"):
		is_exploding = true
		speed = 0
		
		
		var shape = $CollisionShape2D.shape as CircleShape2D
		shape.radius = explosion_radius

	# 🔥 自动按爆炸范围放大视觉
		scale = Vector2(explosion_radius / initial_radius, explosion_radius / initial_radius)
		
		
		print("爆炸判定范围：", shape.radius)
		$AnimatedSprite2D.play("explode")
		
		await get_tree().process_frame  # 等一帧让碰撞范围生效
		
		apply_aoe_damage()  # 🔥 用精确物理查询代替
		

		await $AnimatedSprite2D.animation_finished
		
		shape.radius = original_radius
		queue_free()
		
func apply_aoe_damage():
	var space = get_world_2d().direct_space_state

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = explosion_radius

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = circle_shape
	query.transform = Transform2D(0, position)  # 以当前火球位置为中心
	query.collide_with_areas = true
	query.collision_mask = collision_mask

	var results = space.intersect_shape(query)
	
	print("爆炸命中数：", results.size())

	for item in results:
		var area = item.collider
		if area.is_in_group("enemy") and area.has_method("take_damage"):
			var is_crit = randf() < player.crit_rate
			var final_damage = attack * (2 if is_crit else 1)

			area.take_damage(final_damage, player.knockback_strength)
			area.show_damage_number(final_damage, is_crit)
	

		
