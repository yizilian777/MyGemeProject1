extends Area2D #宣言


@export var speed = 200  # 慢速移动
@export var explosion_scale = 5.0
@export var initial_radius = 10.0  # 🔧 新增：初始判定范围
@export var explosion_radius = 50.0  # 爆炸时的固定判定范围


var shape: CircleShape2D
var original_radius = 0.0  # 存储初始半径
var is_exploding = false

func _process(delta):
	if is_exploding:
		return
	position += Vector2(speed, 0) * delta
	
func _ready():
	$AnimatedSprite2D.play("fly")
	shape = $CollisionShape2D.shape as CircleShape2D
	shape.radius = initial_radius
	original_radius = shape.radius
	await get_tree().create_timer(6).timeout
	queue_free()
	
func _on_area_entered(area: Area2D):
	if is_exploding:
		return
	
	if area.is_in_group("enemy"):
		is_exploding = true
		speed = 0
		
		
		scale = Vector2(explosion_scale, explosion_scale)
		
		var shape = $CollisionShape2D.shape as CircleShape2D
		shape.radius = explosion_radius  # ✅ 实际放大  # 放大碰撞区域
		
		
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
	query.collision_mask = collision_mask  # 换成你敌人的层编号

	var results = space.intersect_shape(query)

	print("爆炸命中数：", results.size())

	for item in results:
		var area = item.collider
		if area.is_in_group("enemy") and area.has_method("take_damage"):
			area.take_damage(1)

		
