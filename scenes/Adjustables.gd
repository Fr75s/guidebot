extends TileMap

var red_switch_toggled = false
var blue_switch_toggled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_reset_level():
	# Reset Red Blocks
	if red_switch_toggled:
		on_red_switch_toggle()
	if blue_switch_toggled:
		on_blue_switch_toggle()

func get_tiles_by_tilename(t_name):
	var ret = []
	var tile_id = get_tileset().find_tile_by_name(t_name)
	for cell in get_used_cells():
		if get_cellv(cell) == tile_id:
			ret.append(cell)
	return ret

func replace_tiles(old_tile, new_tile):
	var old_tile_id = get_tileset().find_tile_by_name(old_tile)
	var new_tile_id = get_tileset().find_tile_by_name(new_tile)
	for tile in get_used_cells():
		if get_cellv(tile) == old_tile_id:
			set_cellv(tile, new_tile_id)

func on_red_switch_toggle():
	red_switch_toggled = not red_switch_toggled
	replace_tiles("red_toggle_off", "blank")
	replace_tiles("red_toggle_on", "red_toggle_off")
	replace_tiles("blank", "red_toggle_on")

func on_blue_switch_toggle():
	blue_switch_toggled = not blue_switch_toggled
	replace_tiles("blue_toggle_off", "blank")
	replace_tiles("blue_toggle_on", "blue_toggle_off")
	replace_tiles("blank", "blue_toggle_on")
