extends Node
var gui_scene # Global Dock Location

# Global vars for string generation
class Seed: 
	var roomCount : int
	var widthMin : int
	var widthMax : int
	var depthMin : int
	var depthMax : int
	var furniture : bool
	var furnRatio : int
	var roof : bool
	var toString: String
	
	func _init(roomCount : int, widthMin : int, widthMax : int, depthMin : int, depthMax : int, furniture : bool, furnRatio : int, roof : bool):
		self.roomCount = roomCount
		self.widthMin = widthMin
		self.widthMax = widthMax
		self.depthMin = depthMin
		self.depthMax = depthMax
		self.furniture = furniture
		self.furnRatio = furnRatio
		self.roof = roof
		self.toString = "M" + str(roomCount) + str(widthMin) + str(widthMax) + str(depthMin) + str(depthMax) + str(furniture) + str(furnRatio) + str(roof)



var save # generation instructions
var rng # random number generator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gui_scene = get_node(".")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_seed():
	# retrieve parameters from GUI
	var roomCount = gui_scene.get_node("ControlsVContainer/RoomCountPanel/HBoxContainer/RoomCount_SpinBox")
	var widthMin  = gui_scene.get_node("ControlsVContainer/RoomDimensionsPanel/Room_Dimensions/HBoxContainerWidth/WidthMin_SpinBox")
	var widthMax = gui_scene.get_node("ControlsVContainer/RoomDimensionsPanel/Room_Dimensions/HBoxContainerWidth/WidthMax_SpinBox")
	var depthMin = gui_scene.get_node("ControlsVContainer/RoomDimensionsPanel/Room_Dimensions/HBoxContainerDepth/DepthMin_SpinBox")
	var depthMax = gui_scene.get_node("ControlsVContainer/RoomDimensionsPanel/Room_Dimensions/HBoxContainerDepth/DepthMax_SpinBox")
	var furniture = gui_scene.get_node("ControlsVContainer/FurniturePanel/VBoxContainer/Furniture_ToggleButton")
	var furnRatio = gui_scene.get_node("ControlsVContainer/FurniturePanel/VBoxContainer/HBoxContainer/Ratio_SpinBox")
	var roof = gui_scene.get_node("ControlsVContainer/RoofPanel/Roof_Toggle_Button")
	
	# create seed object
	var seed = Seed.new(roomCount, widthMin, widthMax, depthMin, depthMax, furniture, furnRatio, roof)
	print("Seed: roomCount: " + seed.roomCount + ", widthMin" + seed.widthMin + ", widthMax" + seed.widthMax + ", depthMin" + seed.depthMin + ", depthMax" + seed.depthMax + ", furniture" + seed.furniture + ", furnRatio" + seed.furnRatio + ", roof" + seed.roof)
