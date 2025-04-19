extends Node2D

@export var float_distance: float = 10
@export var duration: float = 0.3

func start(text: String, is_crit: bool = false):
	$Label.text = text
	$Label.modulate = Color(255, 215, 0) if is_crit else Color(1, 1, 1)
	$Label.scale = Vector2(2, 2) if is_crit else Vector2(1, 1)

	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -float_distance), duration)
	tween.tween_property($Label, "modulate:a", 0.0, duration)
	tween.tween_callback(Callable(self, "queue_free"))
