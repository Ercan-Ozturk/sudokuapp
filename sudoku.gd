extends Node2D

@onready var grid:GridContainer = $GridContainer
@onready var resetButton: Button = $CanvasLayer/Controls/ResetButton
@onready var newButton: Button = $CanvasLayer/Controls/NewButton
@onready var undoButton: Button = $CanvasLayer/Controls/UndoButton
@onready var saveButton: Button = $CanvasLayer/Controls/SaveButton
@onready var statusText: RichTextLabel = $CanvasLayer/GameStatusText
var game_grid = []
var sudokus_list = Sudokus.new().sudokus
var matrix = sudokus_list.pick_random()
var rawMatrix = matrix.duplicate(true)
var actions: Array[SudokuAction]
var selectedButton: Vector2i
var config = ConfigFile.new()
const SIZE = 9
func _ready():
	resetButton.pressed.connect(_onResetGridButtonPressed)
	newButton.pressed.connect(_onNewButtonPressed)
	undoButton.pressed.connect(_onUndoButtonPressed)
	saveButton.pressed.connect(_onSaveButtonPressed)
	#load_game()
	populateGrid()
	_draw()

func createButton(val, isInit, pos:Vector2i):
	if val == 0:
		val = ""
	var button = Button.new()
	button.text = str(val)
	if isInit:
		button.disabled = true
	var styling = StyleBoxFlat.new()
	styling.bg_color = Color("dark_red")
	button.add_theme_stylebox_override("hover", styling)
	button.set("theme_override_font_sizes/font_size", 32)
	button.set("theme_override_colors/font_color", Color("yellow"))

	button.custom_minimum_size = Vector2i(60, 60)
	button.pressed.connect(onButtonPressed.bind(pos))
	grid.add_child(button)
	return button
func onButtonPressed(pos:Vector2i):
	print("Button Pressed: ", pos)
	selectedButton = pos
func _onResetGridButtonPressed():
	statusText.text = "Sudoku is reset"
	resetGrid(false)
func _onNewButtonPressed():
	statusText.text = "New Sudoku"
	resetGrid(true)
func _onUndoButtonPressed():
	undo()
func _onSaveButtonPressed():
	config.set_value("matrix", "sudoku", matrix.duplicate(true))
	config.set_value("matrix", "rawMatrix", rawMatrix.duplicate(true))
	config.save("res://savegame.cfg")
	#save_game()
func undo():
	var lastAction: SudokuAction = actions.pop_back()
	statusText.text = "Undo " + lastAction.to_string()
	game_grid[lastAction.row][lastAction.col].text = ""
	matrix[lastAction.row][lastAction.col] = 0
	if actions.size() == 0:
		undoButton.disabled = true
func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, 
		"pos_y" : position.y,
		"matrix": matrix
	}
	return save_dict
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
func load_game():
	var err = config.load("res://savegame.cfg")
	if err == OK:
		matrix = config.get_value("matrix", "sudoku").duplicate(true)
		rawMatrix = config.get_value("matrix", "rawMatrix").duplicate(true)
		
func populateGrid():
	for i in range(SIZE):
		var row = []
		for j in range(SIZE):
			if rawMatrix[i][j] == 0:
				row.append(createButton(matrix[i][j], false, Vector2i(i, j)))
			else:
				row.append(createButton(matrix[i][j], true, Vector2i(i, j)))
		game_grid.append(row)
	
func placeNumber(row, col, num):
	for i in range(SIZE):
		if matrix[i][col] == num:
			return false
	for j in range(SIZE):
		if matrix[row][j] == num:
			return false
	var s_col = int(col / 3 ) * 3
	var s_row = int(row / 3 ) * 3
	
	@warning_ignore("integer_division")
	for i in range(SIZE/3):
		@warning_ignore("integer_division")
		for j in range(SIZE/3):
			if matrix[i+s_row][j+s_col] == num:
				return false
	changeNumber(row, col, num)
	isSudokuDone()
	return true
func isSudokuDone():
	for i in range(SIZE):
		for j in range(SIZE):
			if matrix[i][j] == 0:
				return
	statusText.text = "Congrats"
	print("Congrats!")
	
func changeNumber(row, col, num):
	game_grid[row][col].text = str(num)
	matrix[row][col] = num
	actions.append(SudokuAction.new(row, col, num))
func eraseGrid():
	game_grid = []
	var children = grid.get_children()
	for c in children:
		grid.remove_child(c)
		c.queue_free()
func resetGrid(isNew):
	actions = []
	undoButton.disabled = true
	if isNew == true:
		matrix = sudokus_list.pick_random()
		rawMatrix = matrix.duplicate(true)
	else:
		matrix = rawMatrix.duplicate(true)
	eraseGrid()
	populateGrid()

func _draw():
	const START_X = 75
	const END_X = 645
	const START_Y = 65
	const END_Y = 645
	const OFFSET = 10
	const BUTTON_SIZE = 60
	const VERTICAL_START = 75
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE+OFFSET), Vector2(END_X, START_Y + BUTTON_SIZE + OFFSET), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*2 + OFFSET*1.5), Vector2(END_X, START_Y + BUTTON_SIZE*2 + OFFSET*1.5), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*3 + OFFSET*2), Vector2(END_X, START_Y + BUTTON_SIZE*3 + OFFSET*2), Color.RED, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*4 + OFFSET*2.5), Vector2(END_X, START_Y + BUTTON_SIZE*4 + OFFSET*2.5), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*5 + OFFSET*2.5), Vector2(END_X, START_Y + BUTTON_SIZE*5 + OFFSET*2.5), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*6 + OFFSET*3), Vector2(END_X, START_Y + BUTTON_SIZE*6 + OFFSET*3), Color.RED, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*7 + OFFSET*3.5), Vector2(END_X, START_Y + BUTTON_SIZE*7 + OFFSET*3.5), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X, START_Y + BUTTON_SIZE*8 + OFFSET*4), Vector2(END_X, START_Y + BUTTON_SIZE*8 + OFFSET*4), Color.SKY_BLUE, 3.0)
	
	draw_line(Vector2(START_X + BUTTON_SIZE, VERTICAL_START), Vector2(START_X + BUTTON_SIZE, END_Y), Color.SKY_BLUE, 3.0)
	@warning_ignore("integer_division")
	draw_line(Vector2(START_X + BUTTON_SIZE*2 + OFFSET/2, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*2 + OFFSET/2, END_Y), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*3 + OFFSET, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*3 + OFFSET, END_Y), Color.RED, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*4 + OFFSET*1.5, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*4 + OFFSET*1.5, END_Y), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*5 + OFFSET*2, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*5 + OFFSET*2, END_Y), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*6 + OFFSET*2, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*6 + OFFSET*2, END_Y), Color.RED, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*7 + OFFSET*2.5, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*7 + OFFSET*2.5, END_Y), Color.SKY_BLUE, 3.0)
	draw_line(Vector2(START_X + BUTTON_SIZE*8 + OFFSET*3, VERTICAL_START), Vector2(START_X + BUTTON_SIZE*8 + OFFSET*3, END_Y), Color.SKY_BLUE, 3.0)
func inputProcess(val):
	if selectedButton != null:
		if placeNumber(selectedButton.x, selectedButton.y, val):
			print("Valid")
			statusText.text = "Valid Placement"
			undoButton.disabled = false
		else:
			print("Invalid placement")
			statusText.text = "Invalid Placement!"
func removeInput():
	if selectedButton:
		var row = selectedButton[0]
		var	col = selectedButton[1]
		game_grid[row][col].text = ""
		matrix[row][col] = 0
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("0"):
		removeInput()
	if event.is_action_pressed("1"):
		inputProcess(1)
	if event.is_action_pressed("2"):
		inputProcess(2)
	if event.is_action_pressed("3"):
		inputProcess(3)
	if event.is_action_pressed("4"):
		inputProcess(4)
	if event.is_action_pressed("5"):
		inputProcess(5)
	if event.is_action_pressed("6"):
		inputProcess(6)
	if event.is_action_pressed("7"):
		inputProcess(7)
	if event.is_action_pressed("8"):
		inputProcess(8)
	if event.is_action_pressed("9"):	
		inputProcess(9)

	


func _on_load_button_pressed() -> void:
	load_game()
	eraseGrid()
	populateGrid()
