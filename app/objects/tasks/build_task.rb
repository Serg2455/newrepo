require 'app/algorithms/pathfinding/pathfinding'
require 'app/objects/entities/item_entity'
require 'app/objects/tasks/haul_task'
require 'app/objects/tasks/task'

# A demolish task object.
# @attr [String] target_name - The name of the target for display purposes
class BuildTask < Task
    attr_accessor :target_name

    # Default constructor.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] assignee - The task assignee
    # @param [Tile] tile - The tile to build
    # @param [Boolean] override_can_perform - (default: false)
    # @return [void]
    def initialize args, assignee, tile, override_can_perform=false
        @goal = {
            row_index: tile.row_index,
            column_index: tile.column_index }
        @goal_radius = 1
        @archived_goal = @goal.dup
        @target_name = tile.name

        super('Build', args, assignee, override_can_perform)
    end

    # Updates the task.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the goal is no longer a buildable tile or is already built
        if not tile.associated_tabs.key?(@name) or
           tile.hit_points >= tile.total_hit_points
            # Completes the task
            @complete = true
            super
            return
        end

        # If the tile does not have enough resources to be built
        if not tile.has_required_resources?
            # Unassigns the task
            hold = @assignee
            @assignee.unassign_task(args)

            # Finds missing resources
            tile.missing_resources.each do |item_class_type, count|
                # Looks for missing resource in inventory
                existing = hold.inventory.find do |item|
                    item.is_a?(item_class_type)
                end
                
                next if existing.nil? or existing.count < count
                # Found missing resource

                # Assigns haul task
                hold.task = HaulTask.new(
                    args,
                    hold,
                    existing,
                    count,
                    tile,
                    true) # Overrides entities requiring hauling enabled

                return
            end # Could not find missing resource in inventory

            # Finds nearest missing resource
            closest_item_entity = nil
            closest_distance = nil

            args.state.entities.each do |entity|
                # Ignores entities that are not missing resources
                next if not entity.is_a?(ItemEntity)
                next if not tile.missing_resources.key?(entity.item_class_type)

                # Tries to pathfind to entity
                result = Pathfinding.a_star(
                    args,
                    hold.row_index,
                    hold.column_index,
                    entity.row_index,
                    entity.column_index,
                    0)
                
                next if result.nil? # Ignores unreachable entities

                # If the entity is nearer than the previous
                if closest_item_entity.nil? or
                   result.actual_cost < closest_distance
                    # Records nearest entity
                    closest_item_entity = entity
                    closest_distance = result.actual_cost
                end
            end

            # Do nothing if there is no nearby resource
            return if closest_item_entity.nil?

            # If there is a nearby resource, assigns new pick up task
            hold.task = PickUpTask.new(
                args,
                hold,
                closest_item_entity,
                tile.missing_resources[closest_item_entity.item_class_type])
            closest_item_entity.associate_task(hold.task)
            return
        end

        # If the assignee has already pathfinded to the tile
        if @goal.nil?
            # Builds the tile
            tile.hit_points += @assignee.building_mult
            tile.hit_points = [ tile.hit_points, tile.total_hit_points ].min
            @assignee.building_experience_points += 0.1
            return
        end
        
        super
    end

    # Gets whether the task is performable under the current conditions.
    # NOTE: True by default. Some tasks, like the build task, may not be
    # performable if, for example, the required materials are unavailable.
    # @param [Args] args - DragonRuby arguments
    # @param [Object] performee - The performee to evaluate based on
    # @return [Boolean] True if performable; false otherwise
    def performable args, performee
        row_index = @archived_goal.row_index
        column_index = @archived_goal.column_index
        tile = args.state.map.grid[row_index][column_index]

        # If the tile does not have enough resources to be built
        if not tile.has_required_resources?
            # Finds missing resources
            tile.missing_resources.each do |item_class_type, count|
                # Looks for missing resource in inventory
                existing = performee.inventory.find do |item|
                    item.is_a?(item_class_type)
                end
                
                next if existing.nil? or existing.count < count
                # Found missing resource
                # The performee could be assigned a haul task and eventually
                # perform the build task
                return true
            end # Could not find missing resource in inventory

            # Finds nearest missing resource
            closest_item_entity = nil
            closest_distance = nil

            args.state.entities.each do |entity|
                # Ignores entities that are not missing resources
                next if not entity.is_a?(ItemEntity)
                next if not tile.missing_resources.key?(entity.item_class_type)

                # Tries to pathfind to entity
                result = Pathfinding.a_star(
                    args,
                    performee.row_index,
                    performee.column_index,
                    entity.row_index,
                    entity.column_index,
                    0)
                
                next if result.nil? # Ignores unreachable entities

                # If the entity is nearer than the previous
                if closest_item_entity.nil? or
                   result.actual_cost < closest_distance
                    # Records nearest entity
                    closest_item_entity = entity
                    closest_distance = result.actual_cost
                end
            end

            # Do nothing if there is no nearby resource
            return false if closest_item_entity.nil?

            # If there is a nearby resource, the performee could be assigned a
            # pick up task and eventually perform the build task
            return true
        end

        return true
    end

    # Gets the string representation of the task.
    # @return [String] The string representation
    def to_s
        return 'Building ' + @target_name
    end
end
