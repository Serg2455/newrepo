# NOTE: The helpers/ directory exists PURELY to support main
require 'app/objects/camera/camera'
require 'app/objects/entities/persons/dwarf_person_entity'
require 'app/objects/entities/persons/goblin_person_entity'
require 'app/objects/entities/item_entity'
require 'app/objects/entities/persons/person_entity'
require 'app/objects/environment/tiles/grass_tile'
require 'app/objects/environment/tiles/tree_tile'
require 'app/objects/environment/map'
require 'app/objects/tasks/task_manager'
require 'app/ui/hud'
require 'app/utils/date_time/date_time'
require 'app/utils/date_time/date'
require 'app/utils/date_time/time'
require 'app/utils/generators/appearance_generator'
require 'app/utils/generators/name_generator'
require 'app/utils/utils'

# Defines time setting defaults.
# @param [Args] args - DragonRuby arguments
# @return [void]
def default_time args
    # Sets the date to August 1, 250 by default
    # Sets the time to 8:00 AM by default
    # NOTE: Goblin Rush displays time in military time
    # NOTE: ALL months in the Goblin Rush universe === twenty-eight days
    args.state.date_time = DateTime.new(Date.new(250, 8, 0, 0), Time.new(8, 0))
    # Sets the world clock settings
    # NOTE: One second IRL === one second in-game (at 1x speed)
    args.state.clock_timer = 0
    args.state.clock_timer_target = FPS
    # Sets the time control speed to 1x by default
    # NOTE: Accepted time control speeds: Paused (or 0x), 1x, 1.5x, 2x, and 3x
    args.state.time_control = 1
    args.state.previous_time_control = 1
end

# Defines map setting defaults.
# @param[Args] args - DragonRuby arguments
# @return [void]
def default_map args
    # Generates a 21x21 randomized map
    args.state.map = Map.new(0, 0, 21, 21)
end

# Defines dwarf setting defaults.
# @param[Args] args - DragonRuby arguments
# @return [void]
def default_dwarves args
    # Generates three randomized dwarves in the center of the map
    # DEBUG: Generates a randomized goblin, too, for combat testing purposes
    args.state.entities = [
        DwarfPersonEntity.new(
            DwarfNameGenerator.generate_full_name,
            DwarfAppearanceGenerator.generate_appearance,
            (args.state.map.num_rows / 2).floor,
            (args.state.map.num_columns / 2).floor - 2
        ),
        DwarfPersonEntity.new(
            DwarfNameGenerator.generate_full_name,
            DwarfAppearanceGenerator.generate_appearance,
            (args.state.map.num_rows / 2).floor,
            (args.state.map.num_columns / 2).floor
        ),
        DwarfPersonEntity.new(
            DwarfNameGenerator.generate_full_name,
            DwarfAppearanceGenerator.generate_appearance,
            (args.state.map.num_rows / 2).floor,
            (args.state.map.num_columns / 2).floor + 2
        ),
        GoblinPersonEntity.new(
            GoblinNameGenerator.generate_full_name,
            GoblinAppearanceGenerator.generate_appearance,
            (args.state.map.num_rows / 2).floor + 2,
            (args.state.map.num_columns / 2).floor
        )
    ]

    # DEBUG: Makes one of the three dwarves an expert lumberjack for skill
    # testing purposes
    args.state.entities[0].woodcutting_experience_points = 7 * 100

    # Makes all dwarves acquaintances by default
    args.state.entities.each do |a|
        next if not a.is_a?(DwarfPersonEntity)

        args.state.entities.each do |b|
            next if a == b or not b.is_a?(DwarfPersonEntity)

            a.relationships[b] = 0
            b.relationships[a] = 0
        end
    end

    # Avoids spawning persons on trees
    for entity in args.state.entities
        next if not entity.is_a?(PersonEntity)
        next if not args.state.map.grid[entity.row_index][entity.column_index]
            .is_a?(TreeTile)

        grass_tile = GrassTile.new(entity.row_index, entity.column_index)
        args.state.map.grid[entity.row_index][entity.column_index] = grass_tile
    end
end

# Defines camera setting defaults.
# @param [Args] args - DragonRuby arguments
# @return [void]
def default_camera args
    # Spawns the camera centered on the map
    args.state.camera = Camera.new(
        args.state.map.global_x(args) + args.state.map.global_w(args) / 2,
        args.state.map.global_y(args) - args.state.map.global_h(args) / 2
    )
end

# Defines GUI setting defaults.
# @param [Args] args - DragonRuby arguments
# @return [void]
def default_gui args
    # Creates the HUD
    args.state.hud = Hud.new(args)
end

# Defines task manager setting defaults.
# @param [Args] args - DragonRuby arguments
# @return [void]
def default_task_manager args
    # Creates the general task manager
    args.state.task_manager = TaskManager.new
end
