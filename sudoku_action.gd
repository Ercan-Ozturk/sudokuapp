extends Node
class_name SudokuAction
var row: int
var col: int
var num: int
func _init(row, col, num) -> void:
	self.row = row
	self.col = col
	self.num = num
