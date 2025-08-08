extends Node2D
@onready var grid:GridContainer = $GridContainer
var game_grid = []
var matrix =  [
	[9, 3, 0, 0, 7, 0, 0, 0, 0],
	[6, 0, 0, 1, 9, 5, 0, 0, 0],
	[0, 5, 8, 0, 0, 0, 0, 6, 0],
	[8, 0, 0, 0, 6, 0, 0, 0, 3],
	[4, 0, 0, 8, 0, 3, 0, 0, 1],
	[7, 0, 0, 0, 2, 0, 0, 0, 6],
	[0, 6, 0, 0, 0, 0, 2, 8, 0],
	[0, 0, 0, 4, 1, 9, 0, 0, 5],
	[0, 0, 0, 0, 8, 0, 0, 7, 9]
]
var selectedButton: Vector2i

const SIZE = 9
func _ready():
	populateGrid()

func createButton(val, isInit, pos:Vector2i):
	if val == 0:
		val = ""
	var button = Button.new()
	button.text = str(val)
	if isInit:
		button.disabled = true
		button.set("theme_override_colors/font_color", Color("yellow"))
		
	button.set("theme_override_font_sizes/font_size", 32)
	button.custom_minimum_size = Vector2i(62, 62)
	button.pressed.connect(onButtonPressed.bind(pos))
	grid.add_child(button)
	return button
func onButtonPressed(pos:Vector2i):
	print("Button Pressed: ", pos)
	selectedButton = pos

func populateGrid():
	for i in range(SIZE):
		var row = []
		for j in range(SIZE):
			if matrix[i][j] == 0:
				row.append(createButton(matrix[i][j], false, Vector2i(i, j)))
			else:
				row.append(createButton(matrix[i][j], true, Vector2i(i, j)))
		game_grid.append(row)
			
func checkIfValid(row, col, num):
	for i in range(SIZE):
		if matrix[i][col] == num:
			return false
	for j in range(SIZE):
		if matrix[row][j] == num:
			return false
	var s_col = int(col / 3 ) * 3
	var s_row = int(row / 3 ) * 3
	
	for i in range(SIZE/3):
		for j in range(SIZE/3):
			if matrix[i+s_row][j+s_col] == num:
				return false
	changeNumber(row, col, num)
	return true
func changeNumber(row, col, num):
	game_grid[row][col].text = str(num)
	matrix[row][col] = num
	
func inputProcess(val):
	if selectedButton:
		if checkIfValid(selectedButton.x, selectedButton.y, val):
			print("Valid")
		else:
			print("Invalid placement")
func _input(event: InputEvent) -> void:
	
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

	
