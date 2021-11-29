extends Node

const MAX_CAMERA_ANGLE = 45
const MIN_CAMERA_ANGLE = -50

var camera_sensitivity = .2

var gravity = -60

onready var screen_width = get_viewport().size.x
onready var screen_height = get_viewport().size.y

signal instance_player(id)
signal player_shot(id, muzzle)
signal remove_bullet(bullet)
signal bullet_hit(damage)

var pea_shooter = preload("res://weapons/Pea_shooter.tscn")
var player = preload("res://mobs/Player.tscn")
var pea = preload("res://weapons/Pea.tscn")
