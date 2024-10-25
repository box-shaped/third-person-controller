
extends Building
@export var health = 50:
	set(value):
		health = value
		if value<=0:
			startdie()
@export var maxHealth = 50
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func Hud_ready():
	updateHealth.connect(get_node("res://HUD/HUD.tscn")._on_castle_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
signal castleGone
func startdie():
	castleGone.emit()

func die():
	self.queue_free()
signal updateHealth(newhealth:int,total:int)
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("castle collided")
	if body.is_in_group("Enemy"): 
		if body.cooldown<=0: 
			body.attack()
			print("attempting attack")
			health -= body.damage
			updateHealth.emit(health,maxHealth)
			print(health)
			
			
