extends Resource
class_name MapData

### Data container for territory setup in editor
### TODO 
### Find a way to store and edit Crest and Army sprite positions in editor
### Pathfinding! 

## Editor use only! 
@export var territories: Array[TerritoryData]

@export var name: String

#func get_territory_id_by_color ( color: Color ) -> int:
    #for territory in territories:
        #if color.is_equal_approx(territory._color):
            ##print("Found a match")
            #return territory.territory_id
    ##printerr("No such colored territory: ", color)
    #return -1
#
### Not used
#func add_territory_from_color( color: Color ) -> TerritoryData:
    #for terr in territories:
        #if color.is_equal_approx(terr._color):
            ## already here
            #return terr
    #var new_territory = TerritoryData.new()
    #new_territory._color = color
    #territories.append( new_territory )
    #print("New Territory Created [" , territories.size() ,"]" )
    #return new_territory
    #
### Not used
#func add_capital( color: Color, position: Vector2i ) -> void:
    #for terr in territories:
        #if color.is_equal_approx(terr._color):
            #terr.capital_position = position
            #print("New Capital Created [" , terr._name ,"]" )
