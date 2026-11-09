@tool
class_name Enemy extends CharacterBody2D

signal direction_changed( new_dir )
signal was_hit( a : AttackArea )
signal was_killed()


@export var health: float = 3
@export var affected_by_gravity : bool = true
@export var face_left_on_start : bool = false

var sprite: Sprite2D
var animation: AnimationPlayer
var damage_area: DamageArea
var hazard_area: HazardArea

var state_machine: EnemyStateMachine
var decision_engine: DecisionEngine
var blackboard : Blackboard

func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return
	setup()
	pass


func setup() -> void:
	blackboard = Blackboard.new()
	blackboard.health = health
	
	for c in get_children():
		if c is AnimationPlayer and not animation:
			animation = c
		elif c is Sprite2D and not sprite:
			sprite = c
		elif c is DamageArea and not damage_area:
			damage_area = c 
			c.damage_taken.connect( _on_damage_taken )
		elif c is HazardArea and not hazard_area:
			hazard_area = c 
			
		elif c is EnemyStateMachine and not state_machine:
			state_machine = c 
		elif c is DecisionEngine and not decision_engine:
			decision_engine = c
		pass
	
	if state_machine and decision_engine:
		state_machine.setup(self,blackboard) 
		decision_engine.enemy = self
		decision_engine.blackboard = blackboard
	else:
		set_physics_process(false)
	pass

## Physics process will move enemy, and call state_machine.physics process
func _physics_process(delta: float) -> void:
	state_machine.change_state(decision_engine.decide())
	if affected_by_gravity:
		velocity+= get_gravity() *(delta)
	state_machine._physics_update(delta)
	move_and_slide()
	
	pass


func change_dir( new_dir : float ) -> void:
	blackboard.dir = new_dir
	direction_changed.emit( new_dir )
	if sprite:
		if new_dir < 0:
			sprite.flip_h = true
			
		elif  new_dir > 0:
			sprite.flip_h = false
	pass

#play animation - plays the animation,after veryfing it exists

func play_animation( anime_name : String ) -> void:
	if animation.has_animation(anime_name):
		animation.play( anime_name )


#handle taking damage
func _on_damage_taken( a : AttackArea )  -> void:
	blackboard.damage_source = a
	blackboard.health -= a.damage
	if blackboard.health <= 0:
		damage_area.queue_free()
		hazard_area.queue_free()
		was_killed.emit( a )
	was_hit.emit( a )
	pass
