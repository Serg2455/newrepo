require 'app/algorithms/pathfinding/path_node'
require 'app/algorithms/pathfinding/pathfinding_result'

# A* pathfinding and helpful associated functions.
class Pathfinding
    # Calculates diagonal (or octile) distance.
    # i.e. (dx + dy) + (√2 - 2) * min(dx, dy)
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] end_column_index - The end column index
    # @return [Integer] The diagonal distance
    def self.chebyshev_dist start_row_index, start_column_index, end_row_index,
                           end_column_index
        dx = (start_column_index - end_column_index).abs
        dy = (start_row_index - end_row_index).abs
        return [ dx, dy ].max
    end

    # Determines whether the distance between two points is within a certain
    # radius.
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] end_column_index - The end column index
    # @param [Float] goal_radius - The radius (default: 0)
    # @return [Boolean] true if reached; false otherwise
    def self.reached_goal start_row_index, start_column_index, end_row_index,
                          end_column_index, goal_radius=0
        return chebyshev_dist(start_row_index,
                              start_column_index,
                              end_row_index,
                              end_column_index) <= goal_radius
    end

    # Runs the A* pathfinding algorithm.
    # @param [Args] args - DragonRuby arguments
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] end_column_index - The end column index
    # @param [Float] goal_radius - The radius (default: 0)
    # @return [PathfindingResult] The result if goal reachable; nil otherwise
    def self.a_star args, start_row_index, start_column_index, end_row_index,
                    end_column_index, goal_radius=0
        # Checks if the goal is already reached
        return PathfindingResult.new if reached_goal(start_row_index,
                                                     start_column_index,
                                                     end_row_index,
                                                     end_column_index,
                                                     goal_radius)

        # Creates start node
        start = PathNode.new(nil, start_row_index, start_column_index, 0, 0)

        # Creates open and closed lists, with start node added to the open list
        open_list = [start]
        closed_list = []

        # While there are still nodes to be processed in the open list
        while not open_list.empty?
            # Gets node with lowest total estimated cost
            q = open_list.min_by(&:f)
            # Deletes node from closed list
            open_list.delete(q)

            # Processes surrounding tiles as explorable pathfinding nodes
            for i in -1..1
                for j in -1..1
                    # Ignores self
                    next if i == 0 and j == 0

                    new_row_index = q.row_index + i
                    new_column_index = q.column_index + j

                    # Ignores tiles out of map bounds
                    next if new_row_index < 0 or
                            new_row_index >= args.state.map.num_rows or
                            new_column_index < 0 or
                            new_column_index >= args.state.map.num_columns

                    cost = args.state.map.grid[new_row_index][new_column_index]
                        .movement_difficulty
                    next if cost.nil? # Ignores walls

                    # Creates successor node
                    g = q.g + cost
                    h = chebyshev_dist(
                            new_row_index,
                            new_column_index,
                            end_row_index,
                            end_column_index) * cost
                    
                    successor = PathNode.new(
                        q,
                        new_row_index,
                        new_column_index,
                        g,
                        h)

                    # If successor reaches goal
                    if reached_goal(successor.row_index,
                                    successor.column_index,
                                    end_row_index,
                                    end_column_index,
                                    goal_radius)
                        actual_cost = successor.g

                        # Backtracks until next step is located
                        # NOTE: The next step refers to the tile that the entity
                        # should go to next to eventually reach the goal
                        # according to the calculated path
                        while successor.parent.row_index != start_row_index or
                              successor.parent.column_index != start_column_index
                            successor = successor.parent
                        end

                        velocity = {
                            x: successor.column_index - start_column_index,
                            y: successor.row_index - start_row_index
                        }

                        return PathfindingResult.new(velocity, actual_cost)
                    end

                    # Determines whether successor should be appended to the
                    # open list
                    skip_flag = false
                    for node in open_list
                        if successor.row_index == node.row_index and
                           successor.column_index == node.column_index and
                           successor.f >= node.f
                            skip_flag = true
                            break
                        end
                    end
                    next if skip_flag

                    for node in closed_list
                        if successor.row_index == node.row_index and
                           successor.column_index == node.column_index and
                           successor.f >= node.f
                            skip_flag = true
                            break
                        end
                    end
                    next if skip_flag

                    # Appends successor to open list
                    open_list << successor
                end
            end

            # Appends node to closed list
            closed_list << q
        end

        return nil
    end

    # Looks for an item entity within a reasonable distance.
    # @param [Args] args - DragonRuby arguments
    # @return [ItemEntity] The closest food item entity within range
    def self.find_nearby_item_entity args, start_row_index, start_column_index,
                                     item_entity_class, search_radius=10
        closest_item_entity = nil
        closest_dist = nil

        search_radius = 10

        args.state.entities.each do |entity|
            # Ignores item entities that do not belong to the given class
            next if not entity.is_a?(item_entity_class)
            
            # Ignores far away item entities
            dist = chebyshev_dist(
                start_row_index,
                start_column_index,
                entity.row_index,
                entity.column_index)
            next if dist > search_radius

            # Pathfinds to the item entity
            result = a_star(
                args,
                start_row_index,
                start_column_index,
                entity.row_index,
                entity.column_index,
                1)
            next if not result # Ignores unreachable results
            
            # Attempts to record nearest item entity
            if closest_item_entity.nil? or result.actual_cost < closest_dist
                # If the item entity is available
                if not entity.tasked_with_class?(Task)
                    # Records nearest item entity
                    closest_item_entity = entity
                    closest_dist = result.actual_cost
                end
            end
        end

        return closest_item_entity
    end
end
