extends Node3D

const room_size: int = 12 + 1

@export var starting_room_prefab = preload("res://rooms/room_t_01.tscn")
@export var open_door_prefab = preload("res://doors/door_open.tscn")
@export var blocked_door_prefab = preload("res://doors/door_closed.tscn")
@export var rooms_4_exits: RoomScene = preload("res://RoomType_4.tres")

var map:Dictionary = {}

var current_coord: Vector2i = Vector2i(0, 0)

@export var branch_length: int = 5
@export var branch_count: int = 3

var start_time: float = 0

enum Dir {
	N,
	S,
	E,
	W
}

func opposite_dir(dir: Dir):
	match dir:
		Dir.N:
			return Dir.S
		Dir.S:
			return Dir.N
		Dir.E:
			return Dir.W
		Dir.W:
			return Dir.E

enum RoomType {
	STARTING,
	FOUR_EXIT,
	#THREE_EXIT,
	#TWO_HALLWAY,
	#TWO_L,
}

enum DoorType {
	OPEN,
	BLOCKED,
	LOCKED
}

const dir_vector = {
	Dir.N : Vector2i(0, 1),
	Dir.S : Vector2i(0, -1),
	Dir.E : Vector2i(1, 0),
	Dir.W : Vector2i(-1, 0),
}

const dir_rotation = {
	Dir.E : 0,
	Dir.S : 90,
	Dir.W : 180,
	Dir.N : 270
}

func _ready() -> void:
	start_time = Time.get_ticks_usec()
	#place starting room
	add_room_placeholder(current_coord)
	instantiate_room(current_coord, RoomType.STARTING)
	
	for i in branch_count:
		generate_branch(current_coord)
	
	# Add missing connections, or close off rooms.
	for room_data: Vector2i in map:
		#print(room_data)
		for dir in [Dir.N, Dir.S, Dir.E, Dir.W]:
			if !map[room_data].connections.has(dir):
				print("Found open door to the ", Dir.find_key(dir), ", filling it in.")
				var neighbour = map.get(room_data + dir_vector[dir])
				print("Checking neighbour: ", neighbour)
				if neighbour != null:
					print("Neighbour found: ", map.find_key(neighbour))
					add_connection(room_data, dir, [DoorType.OPEN, DoorType.BLOCKED].pick_random())
				else:
					add_connection(room_data, dir, DoorType.BLOCKED)

	for room_data: Vector2i in map:
		if room_data == Vector2i.ZERO:
			continue
		match map[room_data].connections.size():
			0:
				printerr("no connections, this shouldn't be possible")
		instantiate_room(room_data, RoomType.FOUR_EXIT)
	var end_time = Time.get_ticks_usec()
	var total_time = (end_time - start_time) / 1000
	print("Map gen done! Total generation time: ", total_time, " milliseconds.")

func generate_branch(coord: Vector2i):
	# loop through branch count, exit early if deadend (no available exits)
	for i in branch_length:
		# get available dirs
		var available_dirs = check_available_dirs(coord)
		if available_dirs.size() == 0:
			printerr("No available rooms, branch ending!")
			break
		# pick dir from available dirs
		var dir = pick_dir(available_dirs)
		# convert to vector
		var dir_vec = dir_vector.get(dir)
		# add room
		add_room_placeholder(coord + dir_vec)
		# add connection
		add_connection(coord, dir, DoorType.OPEN)
		#increment current coord to new coord
		coord = coord + dir_vec
		

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
		print("Coord blocked, map has ", coord, ": ", RoomType.find_key(map.get(coord).id)) 
		return false
	else:
		#print("Coord available, map does not have ", coord)
		return true
		
func pick_dir(dirs :Array[Dir]) -> Dir:
	var pick = dirs.pick_random()
	print("Dir picked: ", Dir.find_key(pick))
	return pick

func add_room_placeholder(coord): #, type: RoomType
	var room_data = RoomData.new()
	room_data.coord = coord
	map[coord] = room_data

func instantiate_room(coord: Vector2i, type: RoomType):
	var room
	match type:
		RoomType.STARTING:
			room = starting_room_prefab
		RoomType.FOUR_EXIT: 
			room = rooms_4_exits.scenes.pick_random()
	room = room.instantiate()
	add_child(room)
	room.position = Vector3(coord.x, 0, coord.y) * room_size
	map[coord].id = type
	#room_data.id = type

func add_connection(coord: Vector2i, dir: Dir, type: DoorType):
	var door
	match type:
		DoorType.OPEN:
			door = open_door_prefab.instantiate()
		DoorType.BLOCKED :
			door = blocked_door_prefab.instantiate()
	add_child(door)
	# add connection to the room data
	map.get(coord).connections.append(dir)
	# add connection to the next room, in the opposite dir - both rooms know about the connection
	var neighbouring_room = map.get(coord + dir_vector.get(dir))
	if neighbouring_room != null:
		neighbouring_room.connections.append(opposite_dir(dir))
	else: 
		print("No neighbouring room found, not adding connection")
	door.position = Vector3(coord.x, 0, coord.y) * room_size
	door.rotation.y = deg_to_rad(dir_rotation.get(dir))

class RoomData:
	var id: int
	var coord: Vector2i
	var connections: Array[Dir]
