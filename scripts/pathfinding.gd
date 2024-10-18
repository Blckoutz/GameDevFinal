extends Node2D
class_name PathFinding
 #Code by 16BitDev on YouTube, https://www.youtube.com/watch?v=0X1ReGZJmXU
 
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var target : CharacterBody2D = owner.get_parent().find_child("Player")
var direction = Vector2.ZERO
 
 
func _ready():
	update_target()
 
 
func update_target():
	navigation_agent_2d.target_position = target.position
 
 
func _on_reaction_time_timeout():
	update_target()
	direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()