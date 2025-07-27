require 'app/objects/tasks/task'

# A pick up task object.
# @attr [ItemEntity] item_entity - The item entity to pick up
# @attr [Integer] count - The number of items to pick up
class PickUpTask < Task
    attr_accessor :item_entity, :count

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [ItemEntity] item_entity - The item entity to pick up
    # @param [Integer] count - The number of items to pick up (default: 1)
    # @return [void]
    def initialize args, assignee, item_entity, count=1
        @goal = {
            row_index: item_entity.row_index,
            column_index: item_entity.column_index }
        @goal_radius = 1
        @archived_goal = @goal.dup
        @item_entity = item_entity
        @count = count

        super('Pick Up', args, assignee)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the goal is no longer the item entity or there are not enough
        # items in the item entity stack
        if @item_entity.nil? or
           @item_entity.row_index != row_index or
           @item_entity.column_index != column_index or
           @item_entity.count < @count
            # Completes the task
            @complete = true
            @item_entity.dissociate_task(self) if @item_entity
            super
            return
        end

        # If the assignee has already pathfinded to the item entity
        if @goal.nil?
            # Removes item(s) from the item entity
            @item_entity.count -= @count
            args.state.entities.delete(@item_entity) if @item_entity.count == 0

            # Adds item(s) to the assignee's inventory
            @assignee.add_to_inventory(@item_entity.item_class_type, @count)
            
            # Completes the task
            @complete = true
            @item_entity.dissociate_task(self) if @item_entity
            super

            return
        end
        
        super
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Picking up ' + @item_entity.name
    end
end
