extends Resource
class_name TerritoryData

@export var is_capital: bool

## Name of Territory
@export var name: String
## Vassals gained when first Conquered
@export var vassals: int
## Income per turn
@export var income: int

## ID of occupying faction
@export var owner_id: int = -1

## Id of territory
var id: int

## Color used for highlights
@export var _color: Color
@export var _mask: Image

	
	
