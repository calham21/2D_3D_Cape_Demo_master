@tool
extends Node2D


var top_point_position_array : Array = []
var bottom_point_position_array : Array = []
var point_position_array : Array = []

@export_group("Amount of Points")
##Determines how many points there are for the bottom of the cape.
@export_range(4, 16) var bottom_point_count : int = 15
##Determines how many points there are for the top of the cape.
@export var top_point_count : int = 12


@export_group("Cape Spacing")
##Total gap between each point.
@export var point_gap : float = 3.0
##Distance between the top fixed points.
@export var top_width: float = 5.0
##Total length of the cape from the top fixed points.
@export var cape_length : float = 10.0

@export_group("Wave")
##Enables or disables whether the cape can wave.
@export var can_wave : bool = true
##Determines the height of the wave.
@export var wave_amplitude : float = 5.0
##Determines the speed of the wave.
@export var wave_frequency : float = 5.0
#Determines how smooth the frequency of the waves are. Just using delta 
#in the process function for this.
var time : float = 0.0

@export_group("Rendering")
@export var render_points : bool = true
@export var render_outline : bool = true
@export var render_polygon : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_cape()

func create_cape():
	var curve = Curve2D.new()
	
	# Calculate the center of the bottom row
	var bottom_width = (bottom_point_count - 1) * point_gap
	var center_x = bottom_width / 2.0  # Center of the bottom points
	
	# Define multiple control points for a smoother curve
	var control_point_count = 5  # Increase this for smoother curves
	
	for i in range(control_point_count):
		var t = i / float(control_point_count - 1)  # Normalize between 0 and 1
		var x = lerp(center_x - top_width / 2, center_x + top_width / 2, t)  # Evenly spread x-values
		var y = -cape_length * (1.0 - pow(t - 0.5, 2) * 4.0)  # Creates a nice arc shape
		curve.add_point(Vector2(x, y))
	
	#Creates new points for the top of the cape
	for i in top_point_count:
		#cape_point.position = Vector2(i * point_gap + bottom_point_count, -cape_length)
		var t = i / float(top_point_count - 1)
		var pos = curve.sample_baked(t * curve.get_baked_length())
		pos.x = center_x + (pos.x - center_x) * top_width
		top_point_position_array.append(pos)
		
	for i in bottom_point_count:
		var pos = Vector2(i * point_gap, 0)
		#Add cape positions to both general array and specific array to use later
		bottom_point_position_array.append(pos)
		
	point_position_array
	queue_redraw()
		

func wave_points():
	for i in range(bottom_point_count):
		var x = i * point_gap
		var y = sin(time * wave_frequency + i * 0.5) * wave_amplitude  #Sine wave formula
		bottom_point_position_array[i] = Vector2(x, y + cape_length)  #Update position
	queue_redraw()
		
func _process(delta: float) -> void:
	time += delta
	if can_wave:
		wave_points()

func _set(property: StringName, value) -> bool:
	if Engine.is_editor_hint():
		if property in ["bottom_point_count", "top_point_count", "point_gap", "top_width", "cape_length"]:
			set(property, value)
			create_cape()
			queue_redraw()
			return true
	return false

func _draw():
	if render_points:
		 #Draw circles at stored positions.
		for pos in bottom_point_position_array:
			draw_circle(pos, 1, Color.YELLOW)
			
		for pos in top_point_position_array:
			draw_circle(pos, 1, Color.RED)
		
		
	if render_polygon:
		var cape_polygon = []
		#Append top points (left-to-right)
		for pos in top_point_position_array:
			cape_polygon.append(pos)
		#Append bottom points in reverse (right-to-left)
		for i in range(bottom_point_position_array.size() - 1, -1, -1):
			cape_polygon.append(bottom_point_position_array[i])
		
		#Draw a filled polygon for the cape:
		draw_polygon(cape_polygon, [Color.BLUE])
		
		if render_outline:
			for i in range(cape_polygon.size()):
				var next_index = (i + 1) % cape_polygon.size()
				draw_line(cape_polygon[i], cape_polygon[next_index], Color.WHITE, 0.2)
				
