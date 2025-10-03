extends Node2D


var broken_tiles_hp : Dictionary
var current_block = "soil"
var distance : float = INF
var block_place_limit = 30.0
var inventory = {
	"soil": 0,
	"mud": 0,
	"stone": 0,
}
@export var block : Dictionary[String, BlockData]
@export var player: CharacterBody2D
@onready var ground: TileMapLayer = $ground


func _physics_process(delta: float) -> void:
	$player/Camera2D/UI/invbox/soilbox/soil_lab.text = ": " + str(inventory["soil"])
	$player/Camera2D/UI/invbox/mudbox/mud_lab.text = ": " + str(inventory["mud"])
	$player/Camera2D/UI/invbox/stonebox/stone_lab.text = ": " + str(inventory["stone"])
	if player:
		distance = (get_global_mouse_position() - player.global_position).length()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var tile_pos = get_snapped_position(get_global_mouse_position())
		
		if event.button_index == MOUSE_BUTTON_LEFT and distance < block_place_limit:
			print(ground.get_cell_atlas_coords(tile_pos))
			var data = ground.get_cell_tile_data(tile_pos)
			var tile_name
			if data:
				tile_name = data.get_custom_data("tile_name")
				print(tile_name)
				print(block[tile_name].hp)
				take_damage(tile_name, tile_pos)
		if is_placeable(event):
			ground.set_cell(tile_pos, block[current_block].source_id, block[current_block].atlas_coords[0])
			inventory[current_block] -= 1
			
	if event is InputEventKey:
		switch_block(event)
	

func get_snapped_position(global_pos : Vector2) -> Vector2i:
	var local_pos = ground.to_local(global_pos)
	var tile_pos = ground.local_to_map(local_pos)
	return tile_pos


func take_damage(tile_name : StringName, tile_pos : Vector2i, amount : float = 1.0):
	if tile_pos not in broken_tiles_hp:
		broken_tiles_hp[tile_pos] = block[tile_name].hp - amount
	else:
		broken_tiles_hp[tile_pos] -= amount
	print(broken_tiles_hp[tile_pos])
	
	var diff = block[tile_name].hp - broken_tiles_hp[tile_pos]
	var next_tile : Vector2i
	
	if diff >= block[tile_name].hp:
		ground.erase_cell(tile_pos)
		broken_tiles_hp.erase(tile_pos)
		if tile_name in inventory:
			inventory[tile_name] += 1
		else:
			inventory[tile_name] = 1
	elif diff < block[tile_name].atlas_coords.size():
		next_tile = block[tile_name].atlas_coords[diff]
		ground.set_cell(tile_pos, block[tile_name].source_id, next_tile)
	print(broken_tiles_hp)


func switch_block(event):
	if event.keycode == KEY_1 and event.pressed:
		current_block = "soil"
	if event.keycode == KEY_2 and event.pressed:
		current_block = "mud"
	if event.keycode == KEY_3 and event.pressed:
		current_block = "stone"


func is_placeable(event) -> bool:
	return event.button_index == MOUSE_BUTTON_RIGHT and distance < block_place_limit and distance > 10 and inventory[current_block] > 0
