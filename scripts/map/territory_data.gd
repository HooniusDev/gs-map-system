extends Resource
class_name TerritoryData

## Name of Territory
@export var name: String:
	set( value ):
		if name != value:
			name = value
			emit_changed()

## ID of occupying faction
@export var factionID: int = -1

## Id of territory
@export var ID: int

## ColorID 
@export var colorID: Color

### Can I Dynamically add properties to Resources? ###
# Vassals gained when first Conquered
@export var vassals: int
## Income per turn
@export var income: int

### Hope these will be gone too ###
## Color used for highlights
@export var _mask: Image

	
