extends Node2D

export var isStatic = false
export var isDraggable = false
var can_drag = false
var preventDouble = false
var timer = 0
var blockPos

func _ready():

	$RigidBody2D.mode = RigidBody2D.MODE_STATIC
	
	var mass = 0
	for node in $RigidBody2D.get_children():
		if(node.is_class("Sprite")):
			mass += 1
	$RigidBody2D.mass = clamp(mass, 1, 100)

func on_Block_enablePhysics():
	if(!isStatic):
		$RigidBody2D.mode = RigidBody2D.MODE_RIGID
		$RigidBody2D.add_central_force(Vector2(0.01,0.01))

func _on_RigidBody2D_input_event(viewport, event, shape_idx):
	if $RigidBody2D.mode == RigidBody2D.MODE_STATIC and isDraggable:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) and !can_drag and !preventDouble:
			can_drag = true
			timer = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			get_node("/root/Root/").currentBlock = self

func _process(delta):
	if can_drag:
		var curPos = get_global_mouse_position()
		position = curPos		
		var x = fmod(position.x, 8)
		var y = fmod(position.y, 8)
		if x < 4:
			position.x -= x
		else:
			position.x += (8-x)
		position.y -= y
		blockPos = position
	elif preventDouble:
		timer += delta
		if(timer > 0.05):
			preventDouble = false

func _input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(BUTTON_RIGHT) and can_drag:
			rotateBlock()
		elif Input.is_mouse_button_pressed(BUTTON_LEFT) and can_drag:
			can_drag = false
			preventDouble = true
			get_node("/root/Root").currentBlock = null
			var currentMousePos = get_global_mouse_position()
			if(currentMousePos.x > 170 && currentMousePos.y < 50):
				call_deferred("free")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
func rotateBlock():
	rotation_degrees += 90
	if(rotation_degrees == 360):
		rotation_degrees = 0
