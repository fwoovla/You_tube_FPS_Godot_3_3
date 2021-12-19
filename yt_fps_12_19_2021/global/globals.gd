extends Node


var team_index = 0

const MAX_CAMERA_ANGLE = 45
const MIN_CAMERA_ANGLE = -50

var camera_sensitivity = .2

var gravity = -60

onready var screen_width = get_viewport().size.x
onready var screen_height = get_viewport().size.y

var single_player = false
var score_limit = 2

signal player_shot(id, b_tag, muzzle)
signal remove_bullet(bullet)
signal bullet_hit(damage, bullet_owner)
signal respawn_player(name)
signal new_score(player, score)
signal game_over(winner)
signal remove_enemy(enemy)

var lobby_scene = preload("res://ui/Lobby.tscn")
var pea_shooter = preload("res://weapons/Pea_shooter.tscn")
var player = preload("res://mobs/Player.tscn")
var pea = preload("res://weapons/Pea.tscn")
var health_pack = preload("res://items/healthpack.tscn")
var blooper = preload("res://weapons/Blooper.tscn")
var bloop = preload("res://weapons/Bloop.tscn")
var sparkle_gun = preload("res://weapons/Sparkle_gun.tscn")
var sparkle = preload("res://weapons/Sparkle.tscn")
var bad_bob = preload("res://mobs/Bad_bob.tscn")
