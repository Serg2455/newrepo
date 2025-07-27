# NOTE: The helpers/ directory exists PURELY to support main
require 'app/objects/environment/map'
require 'app/objects/environment/tiles/tile'
require 'app/objects/entities/persons/dwarf_person_entity'
require 'app/objects/entities/persons/goblin_person_entity'
require 'app/objects/entities/item_entity'
require 'app/objects/entities/persons/person_entity'
require 'app/ui/hud'
require 'app/objects/camera/camera'
require 'app/modules/need_modules'
require 'app/modules/other_modules'
require 'app/objects/tasks/task_manager'
require 'app/utils/date_time/date_time'
require 'app/utils/date_time/date'
require 'app/utils/date_time/time'
require 'app/utils/time_control'

# Resets certain settings each tick.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_reset(args)
    # Resets (mouse-)hovered objects
    # NOTE: hovered_objects is populated as each entity's tick function is
    # individually run
    args.state.hud.hovered_objects = []
end

# Updates game time.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_time(args)
    # If the game is running (not paused)
    if args.state.time_control > 0
        # Increments time
        args.state.clock_timer += 1

        # NOTE: Certain timer targets MUST be adjusted according to time control
        # to account for differences in time control speeds
        adjusted_clock_timer_target =
            TimeControl.adjust(args, args.state.clock_timer_target)

        # If timer meets target
        if args.state.clock_timer >= adjusted_clock_timer_target
            # Resets timer
            args.state.clock_timer = 0
            # Increments game time by one minute
            increment = DateTime.new(Date.new, Time.new(0, 1))
            args.state.date_time.add(increment)
        end
    end
end

# Updates camera.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_camera(args)
    # Updates camera
    args.state.camera.tick(args)

    # Readjusts viewport to camera position and zoom
    args.state.viewport = {
        x: args.grid.w / 2 - args.state.camera.x * args.state.camera.zoom,
        y: args.grid.h / 2 - args.state.camera.y * args.state.camera.zoom,
        w: args.grid.w * args.state.camera.zoom,
        h: args.grid.h * args.state.camera.zoom,
        path: :scene
    }
end

# Updates the game environment and entities.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_game(args)
    # Updates map
    args.state.map.tick(args)
    
    # Updates tile blink
    # NOTE: Some tiles "blink" (turn visible/invisible every half a second) to
    # call special attention to themselves (eg. tree tiles "blink" when they
    # are set to be chopped)
    Tile.blink_timer += 1
    if Tile.blink_timer >= Tile.blink_timer_target
        Tile.blink_timer = 0
        Tile.blink = !Tile.blink
    end

    # Updates entities
    args.state.entities.each do |entity|
        entity.tick(args)
        # If the game is running (not paused)
        if args.state.time_control > 0
            # Updates entity needs
            entity.tick_hunger(args) if entity.is_a?(NeedsFood)
            entity.tick_sleep(args) if entity.is_a?(NeedsSleep)
            entity.tick_fun(args) if entity.is_a?(NeedsFun)
        end
    end

    # If the game is running (not paused)
    if args.state.time_control > 0
        # Increment entity action timer
        Entity.action_timer += 1
        
        adjusted_action_timer_target =
            TimeControl.adjust(args, Entity.action_timer_target)

        # If timer meets timer target
        if Entity.action_timer >= adjusted_action_timer_target
            # Reset timer
            Entity.action_timer = 0

            # Performs entity actions on a turn-based schedule
            args.state.entities.each do |entity|
                if entity.is_a?(HasInventory)
                    if entity.carrying_capacity <= entity.max_carrying_capacity
                        entity.act(args)
                    elsif Entity.slow_turn
                        # NOTE: Overencumbered entities can only take an action
                        # every other turn
                        entity.act(args)
                    end
                else
                    entity.act(args)
                end
            end

            Entity.slow_turn = !Entity.slow_turn
        end
    end
end

# Updates the GUI.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_gui(args)
    # Updates GUI
    args.state.hud.tick(args)
end

# Reorders certain settings lists.
# @param [Args] args - DragonRuby arguments
# @return [void]
def update_reorder(args)
    # Reorders all entities by name and class
    args.state.entities = [PersonEntity, ItemEntity]
        .flat_map do |klass|
            args.state.entities
                .select { |entity| entity.is_a?(klass) }
                .sort_by(&:name)
        end
        .reverse
end
