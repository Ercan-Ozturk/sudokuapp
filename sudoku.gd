extends Node2D
@onready var grid:GridContainer = $GridContainer 
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
var selectedButton

const SIZE = 9
func _ready():
	print(checkIfValid(2, 1, 7))
	populateGrid()

func createButton(val, isInit):
	if val == 0:
		val = ""
	var button = Button.new()
	button.text = str(val)
	if isInit:
		button.disabled = true
		button.set("theme_override_colors/font_color", Color("yellow"))
		
	button.set("theme_override_font_sizes/font_size", 32)
	button.custom_minimum_size = Vector2(62, 62)
	button.pressed.connect(onButtonPressed)
	grid.add_child(button)
	return button
func onButtonPressed():
	print("Button Pressed")
	#selectedButton = 
func populateGrid():
	for i in range(SIZE):
		for j in range(SIZE):
			if matrix[i][j] == 0:
				createButton(matrix[i][j], false)
			else:
				createButton(matrix[i][j], true)
			
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
	return true
	
