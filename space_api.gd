extends Node

var socket := WebSocketPeer.new()

var host := "ws://localhost:9876"
var port := "9876"
var api_version = "0.91"
var client_type = "godot"
var role = "weapons"
var team = "tech"

var ship = { "total_power" : 4,
		 "available_power" : 1,
		 "pilot_power" : 1,
		 "science_power" : 1,
		 "weapon_power" : 1,
		 "shield" : 0
	}

var connected := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var server_message = socket.get_packet().get_string_from_ascii()
			var server_response = JSON.new()
			if server_response.parse(server_message) == OK:
				var response = server_response.data
				if response["type"] == "status":					
					update_ship_status(response["data"])

func update_ship_status(status):
	ship["total_power"] = status["total_power"]
	ship["available_power"] = status["available_power"]
	ship["pilot_power"] = status["pilot_power"]
	ship["science_power"] = status["science_power"]
	ship["weapon_power"] = status["weapon_power"]
	ship["shield"] = status["shield"]
	ship["hp"] = status["hp"]
					
func log_message(message: String) -> void:
	var time := "%s | " % Time.get_time_string_from_system()
	print(time + message)

func _exit_tree() -> void:
	socket.close()

func server_connect(_host, _role, _team):
	host = _host
	role = _role
	team = _team
	var websocket_url : String = "ws://"+host+":"+port
	if socket.connect_to_url(websocket_url) != OK:
		log_message("Unable to connect.")
		set_process(false)
	else:
		var state = socket.get_ready_state()

		while state == WebSocketPeer.STATE_CONNECTING:
			state = socket.get_ready_state() 
			socket.poll()
		connected = true
		var instruction = {"action":"join"}
		send_instruction(instruction)
		print("Connected!")
		
#Adds a single shield
func add_shield() -> void:
	var instruction = {"action":"shield"}
	send_instruction(instruction)

#Shoots selected module target weapon
func shoot(target : int) -> void:
	var instruction = {"action":"shoot", "weapon_id":target}
	send_instruction(instruction)

#Moves one space in direction
func move(direction : String) -> void:
	var instruction = {"action":"move", "direction":direction}
	send_instruction(instruction)

#Moves power up or down for a target module. Enforced by server.
func power(direction, target):
	var instruction = {"action":"power", "direction":direction, "target":target}
	send_instruction(instruction)

func send_instruction(instruction: Dictionary):
	#socket.put_packet(message.to_utf8_buffer())
	instruction["role"] = role
	instruction["team"] = team
	instruction["version"] = api_version
	socket.send_text(JSON.stringify(instruction))
