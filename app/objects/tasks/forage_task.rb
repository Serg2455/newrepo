require 'app/objects/tasks/task'
require 'app/utils/time_control'

# A forage task object.
# @attr [String] target_name - The name of the target for display purposes
# @attr [Integer] timer - The forage completion timer
# @attr [Integer] timer_target - The forage completion timer target
class ForageTask < Task
    attr_accessor :target_name, :timer, :timer_target

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [Tile] tile - The tile to forage
    # @param [Boolean] override_can_perform - (default: false)
    # @return [void]
    def initialize args, assignee, tile, override_can_perform=false
        @goal = {
            row_index: tile.row_index,
            column_index: tile.column_index }
        @goal_radius = 1
        @archived_goal = @goal.dup
        @target_name = tile.name
        @timer = 0
        @timer_target = 15

        super('Forage', args, assignee, override_can_perform)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the goal is no longer a forageable tile
        if not tile.associated_tabs.key?(@name)
            # Completes the task
            @complete = true
            super
            return
        end

        # If the assignee has already pathfinded to the tile
        if @goal.nil?
            # Increments timer
            @timer += @assignee.planting_mult
            # If timer meets target
            if @timer >= TimeControl.adjust(args, @timer_target)
                # Resets timer
                @timer = 0
                # If the forage was successful
                if tile.forage
                    # Adds harvestable to assignee's inventory
                    @assignee.add_to_inventory(
                        tile.harvestable_item_entity_type.new(0, 0)
                            .item_class_type)
                    # Increments assignee's planting experience points
                    @assignee.planting_experience_points += 0.1
                else
                    # Completes the task
                    @complete = true
                    super
                    return
                end
            end
        end
        
        super
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Foraging ' + @target_name
    end
end
