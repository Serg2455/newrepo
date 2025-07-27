require 'app/objects/tasks/task'

# A demolish task object.
# @attr [String] target_name - The name of the target for display purposes
class DemolishTask < Task
    attr_accessor :target_name

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [Tile] tile - The tile to demolish
    # @param [Boolean] override_can_perform - (default: false)
    # @return [void]
    def initialize args, assignee, tile, override_can_perform=false
        @goal = {
            row_index: tile.row_index,
            column_index: tile.column_index }
        @goal_radius = 1
        @archived_goal = @goal.dup
        @target_name = tile.name

        super('Demolish', args, assignee, override_can_perform)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the goal is no longer a demolishable tile
        if not tile.associated_tabs.key?(@name)
            # Completes the task
            @complete = true
            super
            return
        end

        # If the assignee has already pathfinded to the tile
        if @goal.nil?
            # Demolishes the tile
            tile.hit_points -= 10
            return
        end

        super
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Demolishing ' + @target_name
    end
end
