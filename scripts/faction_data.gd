extends Resource
class_name FactionData

## Faction name
@export var name: String
## Int ID of the faction (= index in factions.gd factions array  )
@export var id: int

@export var is_player: bool

@export var primary_color: Color
@export var secondary_color: Color

@export var crest: Texture2D

