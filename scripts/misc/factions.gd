extends Node2D

### Factions manager class

@export var factions: Array[FactionData]

func accuire_territory( factionID: int, territory: Territory ):
	territory._fill_color = factions[factionID].primary_color
	territory._outline_color = factions[factionID].primary_color
	print( factions[factionID].name, " Conquers ", territory.name, "!"  )
	territory.on_conquered( factionID )
