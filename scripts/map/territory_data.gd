extends Resource
class_name TerritoryData

## Name of Territory
@export var name: String:
	set( value ):
		if name != value:
			name = value
			emit_changed()
	get:
		return name

## ID of occupying faction
@export var factionID: int = -1

## Id of territory
@export var ID: int

## ColorID 
@export var colorID: Color

@export var crest_position: Vector2i

### Can I Dynamically add properties to Resources? ###
# Vassals gained when first Conquered
@export var vassals: int
## Income per turn
@export var income: int

### Hope these will be gone too ###
## Color used for highlights
@export var _mask: Image
	
func get_id_as_string() -> String:
	return str(ID)
