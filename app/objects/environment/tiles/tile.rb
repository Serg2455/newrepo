require 'app/enums/stockpile_type'
require 'app/modules/has_display_tags_module'
require 'app/modules/has_functional_descriptors_module'
require 'app/modules/other_modules'
require 'app/modules/tile_modules'
require 'app/objects/tasks/task'
require 'app/utils/color'
require 'app/utils/debug'
require 'app/utils/font'
require 'app/utils/utils'

# A tile abstract.
# @attr [String] name - The tile name
# @attr [String] description - The tile description
# @attr [Character] ascii - The ascii character representation
# @attr [Color] default_color - The default ascii character representation color
# @attr [Color] color - The ascii character representation color
# @attr [Integer] row_index - The row index
# @attr [Integer] column_index - The column index
# @attr [Float] movement_difficulty - The movement difficulty (default: 1)
# @attr [Boolean] in_fov - Whether the tile can be seen by at least one entity
# @attr [Boolean] in_selection - Whether the tile is inside the selection
# @attr [Dictionary[Item, Integer]] drops - The item drop metadata
# @attr [Dictionary[Class, Dictionary[Task, void]]] associated_tasks - Tasks
# @attr [Dictionary[String, void]] associated_tabs - List of tabs associated with the tile
# @attr [Boolean] invincible - Prevents tile from being destroyed
# @attr [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
# NOTE: in_fov exists primarily for debug purposes (to display visible tiles)
# NOTE: associated_tasks is indexed by task class type; use [Task] for all tasks
class Tile
    include HasDisplayTags
    include HasFunctionalDescriptors

    # Defines "blink" class attributes
    # NOTE: Some tiles "blink" (turn visible/invisible every half a second) to
    # call special attention to themselves (eg. tree tiles "blink" when they
    # are set to be chopped)
    class << self
        attr_accessor :blink, :blink_timer, :blink_timer_target
    end

    @blink = false
    @blink_timer = 0
    @blink_timer_target = 30

    attr_accessor :name,
                  :description,
                  :ascii,
                  :default_color,
                  :color,
                  :row_index,
                  :column_index,
                  :movement_difficulty,
                  :in_fov,
                  :in_selection,
                  :drops,
                  :associated_tasks,
                  :associated_tabs,
                  :associated_stockpile_type,
                  :invincible

    # Default constructor.
    # @param [String] name - The tile name
    # @param [String] description - The tile description
    # @param [Character] ascii - The ascii character representation
    # @param [Color] color - The ascii character representation text color
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Float] movement_difficulty - The movement difficulty (default: 1)
    # @param [Dictionary[Item, Integer]] drops - The item drop metadata
    # @param [Dictionary[String, void]] associated_tabs - List of associated tabs
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @param [Boolean] invincible - Prevents tile from being destroyed
    # @return [void]
    def initialize name, description, ascii, color, row_index, column_index,
                   movement_difficulty=1, drops={}, associated_tabs={},
                   associated_stockpile_type=nil, invincible=false
        @name = name
        @description = description
        @ascii = ascii
        @default_color = color
        @color = color
        @row_index = row_index
        @column_index = column_index
        @movement_difficulty = movement_difficulty
        @in_fov = !DEBUG_FLAG_FOG_OF_WAR
        @in_selection = false
        @drops = drops
        @associated_tasks = {}
        @associated_tabs = associated_tabs
        @associated_stockpile_type = associated_stockpile_type
        @invincible = invincible
    end

    # Updates tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If destroyed
        if not @invincible and
           self.is_a?(HasHitPoints) and
           self.destroyed_or_dead?
            # Changes tile depending on whether the previous tile is floor/wall
            tile_class_type = self.wall? ? DirtTile : GrassTile
            change_to(args, tile_class_type.new(
                @row_index,
                @column_index,
                @associated_stockpile_type))
            # Drops items
            drop_items(args)
            return
        end

        # Resets variables
        @in_selection = false
        # NOTE: All tiles are visible all the time unless the fog of war debug
        # flag is triggered; the fog of war debug flag is primarily for debug
        # purposes
        @in_fov = !DEBUG_FLAG_FOG_OF_WAR

        selection_exists = (!args.state.hud.selector.start_position.nil? and
                            !args.state.hud.selector.end_position.nil?)
        
        # If there is an active selection
        if selection_exists
            start_position = args.state.hud.selector.start_position
            end_position = args.state.hud.selector.end_position

            start_row_index =
                [ start_position.row_index, end_position.row_index ].min
            end_row_index =
                [ start_position.row_index, end_position.row_index ].max

            start_column_index =
                [ start_position.column_index, end_position.column_index ].min
            end_column_index =
                [ start_position.column_index, end_position.column_index ].max
            
            # If the tile falls within the active selection
            if row_index >= start_row_index and
               row_index <= end_row_index and
               column_index >= start_column_index and
               column_index <= end_column_index
                # Marks the tile as inside the selection
                @in_selection = true
            end
        end

        # If tasked
        if self.tasked_with_class?(Task)
            # Sets color to blinking color
            @color = Tile.blink ? Color::BLACK : @default_color
        else
            # Resets color to default color
            @color = @default_color
        end

        # If mouse hovered
        if args.inputs.mouse.inside_rect?({
            x: global_x(args),
            y: global_y(args),
            w: global_w(args),
            h: global_h(args)
        })
            # Adds tile to hovered objects list
            args.state.hud.hovered_objects << self
        end
    end

    # Draws tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw args
        # If selected
        if self == args.state.hud.object_details_panel.selected_object
            # Draw border
            args.outputs[:scene].primitives << {
                x: self.local_x(args),
                y: self.local_y(args),
                w: self.local_w,
                h: self.local_h
            }.merge(Color::WHITE).solid!

            # Draw background
            args.outputs[:scene].primitives << {
                x: self.local_x(args) + 1,
                y: self.local_y(args) + 1,
                w: self.local_w - 2,
                h: self.local_h - 2
            }.merge(Color::BLACK).solid!
        else
            # Draw background
            args.outputs[:scene].primitives << {
                x: self.local_x(args),
                y: self.local_y(args),
                w: self.local_w,
                h: self.local_h
            }.merge(Color::BLACK).solid!
        end

        # Determines whether tile should be highlighted (cyan)
        highlight =
            (@in_selection and
            not args.state.hud.task_bar.selected_option.nil? and
            @associated_tabs.key?(args.state.hud.task_bar.selected_option.text))

        # Draws ASCII character representation
        args.outputs[:scene].primitives << {
            x: self.local_x(args) + self.local_w / 2,
            y: self.local_y(args) + self.local_h / 2,
            anchor_x: 0.5,
            anchor_y: 0.5,
            text: @ascii
        }.merge(@in_fov ? (highlight ? Color::CYAN : @color) : Color::BLACK)
         .merge(DEPARTURE_MONO_FONT)
         .label!
    end

    # Draws stockpile borders.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw_stockpile_borders args
        return if @associated_stockpile_type.nil?

        # Gets (stockpile) border color
        border_color = Color::WHITE
        border_color = Color::BROWN if @associated_stockpile_type == StockpileType::WOOD
        border_color = Color::RED if @associated_stockpile_type == StockpileType::FOOD

        # Draw stockpile
        args.outputs[:scene].primitives << {
            x: self.local_x(args),
            y: self.local_y(args),
            w: self.local_w,
            h: self.local_h
        }.merge(border_color).merge({ a: 64 }).solid!
    end

    # Changes tile to another tile.
    # @param [Args] args - DragonRuby arguments
    # @param [Tile] The tile to change to
    # @return [Tile] The original tile
    def change_to args, tile
        hold = self
        args.state.map.grid[@row_index][@column_index] = tile
        args.state.map.num_foliage -= 1 if hold.is_a?(IsFoliage)
        args.state.map.num_foliage += 1 if tile.is_a?(IsFoliage)
        return hold
    end

    # Gets global tile x position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global tile x position
    def global_x args
        args.state.viewport.x + self.local_x(args) * args.state.camera.zoom
    end

    # Gets global tile y position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global tile y position
    def global_y args
        args.state.viewport.y + self.local_y(args) * args.state.camera.zoom
    end

    # Gets global tile width.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global tile width
    def global_w args
        self.local_w * args.state.camera.zoom
    end

    # Gets global tile height.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global tile height
    def global_h args
        self.global_w(args)
    end

    # Gets local tile x position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The local tile x position
    def local_x args
        args.state.map.local_x + @column_index * TILE_SIZE
    end

    # Gets local tile y position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The local tile y position
    def local_y args
        args.state.map.local_y + args.state.map.local_h - (@row_index + 1) * TILE_SIZE
    end

    # Gets local tile width.
    # @return [Float] The local tile width
    def local_w
        TILE_SIZE
    end

    # Gets local tile height.
    # @return [Float] The local tile height
    def local_h
        self.local_w
    end

    # Determines whether the tile is impassable.
    # @return [Boolean] True if wall; false otherwise
    def wall?
        @movement_difficulty.nil?
    end

    # Determines whether the tile is not impassable.
    # @return [Boolean] True if floor; false otherwise
    def floor?
        !self.wall?
    end

    # Determines whether the tile has an associated task of the given task class
    # type.
    # @param [Class] task_class_type - The class type of the associated task
    # @return [Boolean] True if an associated task exists; false otherwise
    def tasked_with_class?(task_class_type)
        return (@associated_tasks.key?(task_class_type) and
               not @associated_tasks[task_class_type].empty?)
    end

    # Associates a task with the tile.
    # @ param [Task] task_to_associate_with - The task to associate
    # @ return [void]
    def associate_task(task_to_associate_with)
        # Indexes Task if not indexed yet
        @associated_tasks[Task] = {} if not @associated_tasks.key?(Task)
        # Associates task with tile, broadly
        @associated_tasks[Task][task_to_associate_with] = nil

        task_class_type = task_to_associate_with.class

        # If task class type not indexed yet
        if not @associated_tasks.key?(task_class_type)
            # Indexes task class type
            @associated_tasks[task_class_type] = {}
        end

        # Associates task with tile and task class type
        @associated_tasks[task_class_type][task_to_associate_with] = nil
    end

    # Dissociates a task with the tile.
    # @param [Task] task_to_dissociate_with - The task to dissociate
    # @return [void]
    def dissociate_task(task_to_dissociate_with)
        # Indexes Task if not indexed yet
        @associated_tasks[Task] = {} if not @associated_tasks.key?(Task)
        # Dissociates task with tile, broadly
        @associated_tasks[Task].delete(task_to_dissociate_with)

        task_class_type = task_to_dissociate_with.class

        # If task class type not indexed yet
        if not @associated_tasks.key?(task_class_type)
            # Indexes task class type
            @associated_tasks[task_class_type] = {}
        end

        # Dissociates task with tile and task class type
        @associated_tasks[task_class_type].delete(task_to_dissociate_with)
    end

    # Drops items on the ground.
    # @args [Args] args - DragonRuby arguments
    # @return [void]
    def drop_items args
        @drops.each do |item_entity_class, count|
            existing_item_stack = args.state.entities.find do |entity|
                entity.is_a?(item_entity_class) and
                entity.column_index == @column_index and
                entity.row_index == @row_index
            end

            # If there is an existing item stack
            if existing_item_stack
                # Updates item stack count
                existing_item_stack.count += count
            else
                # Creates new item stack
                args.state.entities << item_entity_class.new(
                    @row_index, @column_index, count)
            end
        end
    end
end
