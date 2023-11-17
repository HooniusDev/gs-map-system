extends Node2D
class_name Territory

## Node Container for Territory

## Index in the Territory node 
@export var id: int = -1

@export var data: TerritoryData

func _ready() -> void:

	pass


func setup( id: int, data: TerritoryData ):
	self.id = id
	self.data = data
	pass



