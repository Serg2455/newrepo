require 'app/algorithms/pathfinding/pathfinding'
require 'app/objects/tasks/task'

# A haul task object.
# @attr [ItemEntity] item_entity - The item to haul
# @attr [Integer] count - The number of items to haul (default: nil or all)
# @attr [Tile] tile - The tile to haul to
class HaulTask < Task
    attr_accessor :item, :count, :tile

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [ItemEntity] item - The item to haul
    # @param [Integer] count - The number of items to haul (nil === all)
    # @param [Tile] tile - The tile to haul to
    # @param [Boolean] override_can_perform - (default: false)
    # @return [void]
    def initialize args, assignee, item, count, tile, override_can_perform=false
        @goal = {
            row_index: tile.row_index,
            column_index: tile.column_index }
        @goal_radius = 0
        @archived_goal = @goal.dup
        @item = item
        @count = count.nil? ? item.count : count

        super('Haul', args, assignee, override_can_perform)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the item is no longer in the assignee's inventory
        if not @assignee.inventory.include?(@item) or
           (@count and @count < @item.count)
            # Completes the task
            @complete = true
            super
            return
        end

        # If the assignee has already pathfinded to the tile
        if @goal.nil?
            item_entity_class_type = @item.class.new.item_entity_class_type
            
            # Removes item(s) from the assignee's inventory
            @assignee.remove_from_inventory(@item.class, @count)

            # If the tile is a building tile and needs the item(s) as resource
            if tile.associated_tabs.key?('Build') and
               not tile.has_required_resources? and
               tile.missing_resources.include?(@item.class)
                # Adds item(s) to the building tile
                num_needed =
                    (!tile.drops.key?(item_entity_class_type) ?
                    tile.required_resources[@item.class] :
                    (tile.required_resources[@item.class] -
                    tile.drops[item_entity_class_type]))
                
                if not tile.drops.key?(item_entity_class_type)
                    tile.drops[item_entity_class_type] = 0
                end
                
                tile.drops[item_entity_class_type] += num_needed

                @count -= num_needed

                # If the building tile took up all the item(s)
                if @count == 0
                    # Completes the task
                    @complete = true
                    super
                    return
                end # Otherwise, spill overflow onto the ground
            end

            # If the tile is a crafting tile and needs the item(s) as resource, added for crafting
            if tile.associated_tabs.key?('Craft') and
               not tile.has_required_resources? and
               tile.missing_resources.include?(@item.class)
                # Adds item(s) to the crafting tile
                num_needed =
                    (!tile.drops.key?(item_entity_class_type) ?
                    tile.required_resources[@item.class] :
                    (tile.required_resources[@item.class] -
                    tile.drops[item_entity_class_type]))
                
                if not tile.drops.key?(item_entity_class_type)
                    tile.drops[item_entity_class_type] = 0
                end
                
                tile.drops[item_entity_class_type] += num_needed

                @count -= num_needed

                # If the crafting tile took up all the item(s)
                if @count == 0
                    # Completes the task
                    @complete = true
                    super
                    return
                end # Otherwise, spill overflow onto the ground
            end

            # Adds item(s) to the tile
            existing = Pathfinding.find_nearby_item_entity(
                args,
                row_index,
                column_index,
                @item.class,
                0)
            
            # Adds item(s) to the existing item entity stack
            existing.count += @count if existing

            # Creates a new item entity stack (if no existing stack)
            args.state.entities << item_entity_class_type.new(
                                        row_index,
                                        column_index,
                                        @count) if existing.nil?
            
            # Completes the task
            @complete = true
            super

            return
        end
        
        super
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Hauling ' + @item.name
    end
end
