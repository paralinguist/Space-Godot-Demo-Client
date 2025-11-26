extends Node2D

var socket := WebSocketPeer.new()

#Change these variables as needed
var server_ip := "127.0.0.1"
var role := "weapons"
var team := "tech"

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if str(SpaceApi.ship["available_power"]) != $Panel/TextAvailablePower.text:
		$Panel/PilotPower.value = SpaceApi.ship["pilot_power"]
		$Panel/SciencePower.value = SpaceApi.ship["science_power"]
		$Panel/WeaponsPower.value = SpaceApi.ship["weapon_power"]
		$Panel/TextAvailablePower.text = str(SpaceApi.ship["available_power"])

func _exit_tree() -> void:
	socket.close()

func _on_connect_pressed() -> void:
	SpaceApi.server_connect(server_ip, role, team)

func _on_up_button_pressed() -> void:
	SpaceApi.add_shield()

#Shoots five every time. I sure hope five is a weapon!
func _on_down_button_button_down() -> void:
	if $Panel/ChkMissiles.button_pressed:
		SpaceApi.shoot("missile")
	else:
		SpaceApi.shoot("laser")

func _on_left_button_pressed() -> void:
	SpaceApi.move("left")

func _on_right_button_pressed() -> void:
	SpaceApi.move("right")

#The following two functions allow for power levels to be adjusted according
#To the rules. These aren't elegant, but they work.
func _on_pilot_power_value_changed(value: float) -> void:
	if SpaceApi.ship["pilot_power"] < value and int($Panel/TextAvailablePower.text) >= 1:
		SpaceApi.power("up", "pilot")
	elif SpaceApi.ship["pilot_power"] > value:
		SpaceApi.power("down", "pilot")
	else:
		$Panel/PilotPower.value = SpaceApi.ship["pilot_power"]

func _on_science_power_value_changed(value: float) -> void:
	if SpaceApi.ship["science_power"] < value and int($Panel/TextAvailablePower.text) >= 1:
		SpaceApi.power("up", "science")
	elif SpaceApi.ship["science_power"] > value:
		SpaceApi.power("down", "science")
	else:
		$Panel/SciencePower.value = SpaceApi.ship["science_power"]


func _on_weapons_power_value_changed(value: float) -> void:
	if SpaceApi.ship["weapon_power"] < value and int($Panel/TextAvailablePower.text) >= 1:
		SpaceApi.power("up", "weapons")
	elif SpaceApi.ship["weapon_power"] > value:
		SpaceApi.power("down", "weapons")
	else:
		$Panel/WeaponsPower.value = SpaceApi.ship["weapon_power"]
