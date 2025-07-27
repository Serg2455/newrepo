require 'app/algorithms/pathfinding/pathfinding'
require 'app/modules/other_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/items/item'
require 'app/utils/time_control'

# Grants class instances food need.
# @attr [Float] hunger - The currenet hunger
# @attr [Float] max_hunger - The max hunger
# @attr [Float] hunger_timer - The hunger timer
# @attr [Float] hunger_timer_target - The hunger timer target
module NeedsFood
    attr_accessor :hunger, :max_hunger, :hunger_timer, :hunger_timer_target

    # Determines hunger status from hunger percentage (hunger / max_hunger).
    # @return [String] The hunger status
    def hunger_status
        return 'Full' if hunger >= max_hunger * 0.5
        return 'Hungry' if hunger >= max_hunger * 0.25
        return 'Starving'
    end

    # Updates hunger.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick_hunger args
        return if self.destroyed_or_dead?

        # Increments timer
        @hunger_timer += 1

        # If timer meets target
        if @hunger_timer >= TimeControl.adjust(args, @hunger_timer_target)
            # Resets timer
            @hunger_timer = 0
            # Decrements hunger
            @hunger -= 1
            @hunger = @hunger.clamp(0, 100)

            # If hunger at or below zero
            if @hunger <= 0 and self.is_a?(HasHitPoints)
                # Decrements hit points
                @hit_points -= 1
                @hit_points = @hit_points.clamp(0, @total_hit_points)
            end
        end
    end

    # Takes an action if hungry.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def act_hunger args
        return if hunger_status == 'Full' # If hungry

        # Looks for food in inventory
        food_item = nil
        if self.is_a?(HasInventory)
            @inventory.each do |inventory_item|
                next if not inventory_item.is_a?(FoodItem)
                # Found food item
                food_item = inventory_item
                break
            end
        end
        
        # If food item found
        if food_item
            # Eats food
            @hunger += food_item.nourishment
            @hunger = @hunger.clamp(0, @max_hunger)
            food_item.count -= 1
            @inventory.delete(food_item) if food_item.count == 0
        elsif @task.nil? or not (@task.is_a?(PickUpTask) and
              @task.item_entity.is_a?(FoodItemEntity))
            # Looks for nearby food item entity
            food_item_entity = Pathfinding.find_nearby_item_entity(
                args,
                @row_index,
                @column_index,
                FoodItemEntity)

            # If food item entity found
            if food_item_entity
                # Unassigns task (if any)
                self.unassign_task(args) if @task
                # Assigns new pick up (food item entity) task
                @task = PickUpTask.new(args, self, food_item_entity)
                food_item_entity.associate_task(@task)
            end
        end
    end
end

# Grants class instances sleep need.
# @attr [Float] sleep - The currenet sleep
# @attr [Float] max_sleep - The max sleep
# @attr [Float] sleep_timer - The sleep timer
# @attr [Float] sleep_timer_target - The sleep timer target
module NeedsSleep
    attr_accessor :sleep, :max_sleep, :sleep_timer, :sleep_timer_target

    # Determines sleep status from sleep percentage (sleep / max_sleep).
    # @return [String] The sleep status
    def sleep_status
        return 'Rested' if sleep >= max_sleep * 0.5
        return 'Tired' if sleep >= max_sleep * 0.25
        return 'Exhausted'
    end

    # Updates sleep.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick_sleep args
        return if self.destroyed_or_dead?

        # Increments timer
        @sleep_timer += 1

        # If timer meets target
        if @sleep_timer >= TimeControl.adjust(args, @sleep_timer_target)
            # Resets timer
            @sleep_timer = 0
            # Decrements sleep
            @sleep -= 1
            @sleep = @sleep.clamp(0, 100)

            # If sleep at or below zero
            if @sleep <= 0 and self.is_a?(HasHitPoints)
                # Decrements hit points
                @hit_points -= 1
                @hit_points = @hit_points.clamp(0, @total_hit_points)
            end
        end
    end
end

# Grants class instances fun need.
# @attr [Float] fun - The currenet fun
# @attr [Float] max_fun - The max fun
# @attr [Float] fun_timer - The fun timer
# @attr [Float] fun_timer_target - The fun timer target
module NeedsFun
    attr_accessor :fun, :max_fun, :fun_timer, :fun_timer_target

    # Determines fun status from fun percentage (fun / max_fun).
    # @return [String] The fun status
    def fun_status
        return 'Entertained' if fun >= max_fun * 0.5
        return 'Bored' if fun >= max_fun * 0.25
        return 'Miserable'
    end

    # Updates fun.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick_fun args
        return if self.destroyed_or_dead?
        
        # Increments timer
        @fun_timer += 1

        # If timer meets target
        if @fun_timer >= TimeControl.adjust(args, @fun_timer_target)
            # Resets timer
            @fun_timer = 0
            # Decrements fun
            @fun -= 1
            @fun = @fun.clamp(0, 100)
        end
    end
end
