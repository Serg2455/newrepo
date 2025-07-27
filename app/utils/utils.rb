# Defines constants
FPS = 60
TILE_SIZE = 32

# Gets the row index of the tile the mouse is hovered over
# @param [Args] args - DragonRuby arguments
# @return The mouse row index
def mouse_row_index args
    delta = args.state.map.global_y(args) - args.inputs.mouse.y
    row_index = (delta / (TILE_SIZE * args.state.camera.zoom)).floor
    row_index.clamp(0, args.state.map.num_rows - 1)
end

# Gets the column index of the tile the mouse is hovered over
# @param [Args] args - DragonRuby arguments
# @return The mouse column index
def mouse_column_index args
    delta = args.inputs.mouse.x - args.state.map.global_x(args)
    column_index = (delta / (TILE_SIZE * args.state.camera.zoom)).floor
    column_index.clamp(0, args.state.map.num_columns - 1)
end
