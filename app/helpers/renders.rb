# NOTE: The helpers/ directory exists PURELY to support main
require 'app/objects/entities/item_entity'
require 'app/objects/entities/persons/person_entity'
require 'app/utils/color'

# Clears the screen.
# @param [Args] args - DragonRuby arguments
# @return [void]
def clear_screen args
    # Draws a black rectangle
    args.outputs.primitives << {
        x: 0,
        y: 0,
        w: args.grid.w,
        h: args.grid.h
    }.merge(Color::BLACK).solid!
end

# Renders the game environment and entities.
# @param [Args] args - DragonRuby arguments
# @return [void]
def render_game args
    # Draws the map
    args.state.map.draw(args)

    # Draws entities
    args.state.entities.each { |entity| entity.draw(args) }

    # If the Zone activity is selected
    if ZonePanel.visible?(args)
        # Draws the stockpile borders
        args.state.map.grid.each do |row|
            row.each { |tile| tile.draw_stockpile_borders(args) }
        end
    end
    
    # Re-draws the selected object (if any)
    # NOTE: Doing this acts as a quick and dirty way to ensure the selected
    # object is drawn ON TOP of every other object on the same tile
    if args.state.hud.object_details_panel.selected_object
        args.state.hud.object_details_panel.selected_object.draw(args)
    end

    # Draws the game viewport
    args.outputs.primitives << args.state.viewport
end

# Renders the GUI.
# @param [Args] args - DragonRuby arguments
# @return [void]
def render_gui args
    # Draws the HUD
    args.state.hud.draw(args)
end
