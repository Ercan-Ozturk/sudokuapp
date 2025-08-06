extends Node2D

var matrix = []

const SIZE = 9
func _init():
	for x in range(SIZE):
		matrix.append([])
		matrix[x]=[]	
		for y in range(SIZE):
			matrix[x].append([])
			matrix[x][y]=0
	#matrix[3][2] = 5

	print(checkIfValid(0, 1, 5))
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
	
