class_name Enemystate extends Node

@export var animation_name : String

var statemachine : EnemyStateMachine
var enemy : Enemy
var blackboard : Blackboard

func enter() -> void: pass
func re_enter() -> void: pass
func exit() -> void: pass
func  _physics_process(delta: float) -> void: pass
