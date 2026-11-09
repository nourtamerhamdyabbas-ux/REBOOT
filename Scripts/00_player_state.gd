@icon("res://player/states/state.svg")
class_name PlayerState
extends Node
var player: Player
var next_state: PlayerState

#region /// State references
@onready var run: Node = %Run
@onready var idle: PlayerStateIdle = %Idle
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall
@onready var crouch: PlayerStateCrouch = %Crouch
@onready var attack: PlayerStateAttack = %Attack
@onready var take_damage: PlayerStateTakeDamage = %TakeDamage
@onready var death: PlayerStateDeath = %Death
@onready var dash: PlayerStateDash = %Dash
@onready var ground_slam: PlayerStateGroundSlam = %GroundSlam
@onready var ball: PlayerStateBall = %ball

#endregion



func _init() -> void:
	pass




func enter() -> void:
	pass





func exit() -> void:
	pass


func handle_input(_event: InputEvent)-> PlayerState:
	return next_state


func process(_delta: float) -> PlayerState:
	
	return next_state
	
	



func physics_process(_delta: float) -> PlayerState:
	return next_state
