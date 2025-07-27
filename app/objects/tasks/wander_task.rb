require 'app/algorithms/pathfinding/pathfinding'
require 'app/objects/tasks/task'

# A wander task object.
class WanderTask < Task
    # Defines constants
    MIN_RANGE = 4
    MAX_RANGE = 12

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @return [void]
    def initialize args, assignee
        # Calculates the tiles within range
        within_range = []
        
        start_row_index = [ 0, assignee.row_index - MAX_RANGE ].max
        end_row_index = [
            args.state.map.num_rows - 1,
            assignee.row_index + MAX_RANGE ].min

        start_column_index = [ 0, assignee.column_index - MAX_RANGE ].max
        end_column_index = [
            args.state.map.num_columns - 1,
            assignee.column_index + MAX_RANGE ].min

        for i in start_row_index..end_row_index
            for j in start_column_index..end_column_index
                # Calculates distance
                dist = Pathfinding.chebyshev_dist(
                    assignee.row_index,
                    assignee.column_index,
                    i,
                    j)
                # Ignores tiles outside range
                next if dist < MIN_RANGE or dist > MAX_RANGE
                # Ignores wall tiles
                next if args.state.map.grid[i][j].wall?
                # Adds tile to the list of tiles within range
                within_range << { row_index: i, column_index: j }
            end
        end

        # Sets goal to a random tile within range
        # NOTE: Sampling until the program finds a reachable tile is a hacky
        # solution to prevent lag on wander task initialization. The "solution"
        # breaks and will generate lag in circumstances where dwarves have many
        # unreachable tiles within range
        while true
            @goal = within_range ? within_range.sample : nil
            break if @goal.nil? # There are no tiles within range
            # Ignores unreachable tiles
            next if Pathfinding.a_star(
                args,
                assignee.row_index,
                assignee.column_index,
                @goal.row_index,
                @goal.column_index).nil?
            break
        end
        @goal_radius = 0
        @archived_goal = @goal.dup

        super('Wander', args, assignee)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # Completes task if goal no longer exists
        @complete = true if @goal.nil?

        super
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Wandering'
    end
end
