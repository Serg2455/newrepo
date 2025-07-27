# A task abstract.
# @attr [String] name - The task name
# @attr [Object] assignee - The task assignee
# @attr [Boolean] complete - Whether the task is complete
# @attr [Hash] goal - The task goal (use goal.row_index, goal.column_index)
# @attr [Float] goal_radius - How close the assignee must be to the goal
# @attr [Hash] archived_goal - The archived goal
# @attr [Boolean] override_can_perform - Whether task overrides entity settings
class Task
    attr_accessor :name,
                  :assignee,
                  :complete,
                  :goal,
                  :goal_radius,
                  :archived_goal,
                  :override_can_perform

    # Default constructor.
    # @param [String] name - The task name
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [Boolean] override_can_perform - (default: false)
    # @return [void]
    def initialize name, args, assignee, override_can_perform=false
        @name = name
        @assignee = assignee
        @complete = false
        @override_can_perform = override_can_perform
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # Removes the task if complete
        if @complete
            row_index = @archived_goal.row_index
            column_index = @archived_goal.column_index
            tile = args.state.map.grid[row_index][column_index]

            tile.dissociate_task(self)

            @assignee.task = nil if @assignee.task == self

            return
        end
        
        # If there is a goal to pathfind to
        if @goal
            # Tries to pathfind to the goal
            result = Pathfinding.a_star(
                args,
                @assignee.row_index,
                @assignee.column_index,
                @goal.row_index,
                @goal.column_index,
                @goal_radius)
            
            # If the goal is unreachable
            if result.nil?
                # Unassigns task
                @assignee.unassign_task(args)
                return
            end
            
            # If the goal is already reached, sets goal to nil
            if result.velocity.x == 0 and result.velocity.y == 0
                # Sets goal to nil
                @goal = nil
                return
            end
            
            # Sets the assignee to move towards the goal
            @assignee.velocity.x = result.velocity.x
            @assignee.velocity.y = result.velocity.y
        end
    end

    # Gets whether the task is performable under the current conditions.
    # NOTE: True by default. Some tasks, like the build task, may not be
    # performable if, for example, the required materials are unavailable.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] performee - The performee to evaluate based on
    # @return [Boolean] True if performable; false otherwise
    def performable args, performee
        true
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        # NOTE: This should never happen since this method should always be
        # overrode by a concrete subclass
        return 'Unknown'
    end
end
