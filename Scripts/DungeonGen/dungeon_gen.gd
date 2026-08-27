extends Node3D

const room_size: int = 12 + 1

@export var room_prefab = preload("res://rooms/dummy_room.tscn")

var step_count: int = 0
var map:Dictionary = {}

enum Dir {
	N,
	S,
	E,
	W
}

const dir_vector = {
	Dir.N : Vector2i(0, 1),
	Dir.S : Vector2i(0, -1),
	Dir.E : Vector2i(1, 0),
	Dir.W : Vector2i(-1, 0),
}

var current_coord: Vector2i = Vector2i(0, 0)
var branch_count: int = 10

func _ready() -> void:
	generate_branch()
	
func generate_branch():
	#place starting room
	add_room(current_coord)
	for i in branch_count:
		# get available dirs
		var available_dirs = check_available_dirs(current_coord)
		if available_dirs.size() == 0:
			printerr("No available rooms, branch ending!")
			break
		# pick dir from available dirs
		var dir = pick_dir(available_dirs)
		# convert to vector
		var dir_vec = dir_vector.get(dir)
		# add room
		add_room(current_coord + dir_vec)
		current_coord = current_coord + dir_vec 
		

func check_available_dirs(coord) -> Array[Dir]:
	var available_dirs : Array[Dir] = []
	for dir in dir_vector:
		#print(Dir.find_key(dir))
		if check_coord_available(coord + dir_vector.get(dir)):
			available_dirs.append(dir)
			print("Coord available: ", Dir.find_key(dir), " ", coord)
		else:
			print("Coord unavailable: ", Dir.find_key(dir), " ", coord)
		pass
	return available_dirs

func check_coord_available(coord: Vector2i) -> bool:
	if map.has(coord):
		#print("Coord blocked, map has ", coord, ": ", map.get(coord).name) 
		return false
	else:
		#print("Coord available, map does not have ", coord)
		return true
		
func pick_dir(dirs :Array[Dir]) -> Dir:
	var pick = dirs.pick_random()
	print("Dir picked: ", Dir.find_key(pick))
	return pick

func add_room(coord):
	var room = room_prefab.instantiate()
	map.get_or_add(coord, room) 
	add_child(room)
	room.position = Vector3(coord.x, 0, coord.y) * room_size
