extends Node2D

## The URL we will connect to.
var websocket_url := "ws://localhost:9876"
var api_version = "0.91"
var client_type = "godot"
var role = "weapons"
var team = "techn"

var socket := WebSocketPeer.new()

var connected := false

func log_message(message: String) -> void:
	var time := "%s | " % Time.get_time_string_from_system()
	print(time + message)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var server_message = socket.get_packet().get_string_from_ascii()
			var server_response = JSON.new()
			if server_response.parse(server_message) == OK:
				var response = server_response.data
				if response["type"] == "status":
					log_message("Here is the ship status: ")
					print(response["data"])

func _exit_tree() -> void:
	socket.close()

func _on_button_pressed() -> void:
	if socket.connect_to_url(websocket_url) != OK:
		log_message("Unable to connect.")
		set_process(false)
	else:
		var state = socket.get_ready_state()

		while state == WebSocketPeer.STATE_CONNECTING:
			state = socket.get_ready_state() 
			socket.poll()
		connected = true
		#initial connection string - sub "lockpick" for selected role
		var instruction = {"action":"join"}
		send(instruction)
		print("Connected!")

func send(instruction: Dictionary):
	#socket.put_packet(message.to_utf8_buffer())
	instruction["role"] = role
	instruction["team"] = team
	instruction["version"] = api_version
	socket.send_text(JSON.stringify(instruction))



func _on_up_button_pressed() -> void:
	var instruction = {"action":"shield"}
	send(instruction)


func _on_down_button_button_down() -> void:
	var instruction = {"action":"shoot", "weapon_id":"5"}
	send(instruction)


func _on_left_button_pressed() -> void:
	var instruction = {"action":"move", "direction":"left"}
	send(instruction)


func _on_right_button_pressed() -> void:
	var instruction = {"action":"move", "direction":"right"}
	send(instruction)
