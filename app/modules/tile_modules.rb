require 'app/utils/time_control'

# Tags class instances as foliage.
# E.g. bushes, trees.
# NOTE: The ratio of tiles with this tag over tiles without this tag is used to
# determine new foliage growth.
module IsFoliage
end

# Tags class instances as forageable.
# E.g. berry bushes, apple trees.
# @attr [Class] harvestable_item_entity_type - The harvestable item entity type
# @attr [Integer] current_harvestables - The current number of harvestables
# @attr [Integer] max_harvestables - The maximum number of harvestables
# @attr [Float] spawn_timer - The harvestable spawn timer
# @attr [Float] spawn_timer_target - The harvestable spawn timer target
module Forageable
    attr_accessor :harvestable_item_entity_type, :current_harvestables,
                  :max_harvestables, :spawn_timer, :spawn_timer_target

    # Updates harvestables.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick_forage args
        # If the game is running (not paused)
        if args.state.time_control > 0
            # If current harvestables is not maxed
            if @current_harvestables < @max_harvestables
                # Increments timer
                @spawn_timer += 1
                # If timer meets target
                if @spawn_timer >= TimeControl.adjust(args, @spawn_timer_target)
                    # Resets timer
                    @spawn_timer = 0
                    # Increments variables
                    @current_harvestables += 1
                    @drops[harvestable_item_entity_type] += 1
                end
            end
        end

    end

    # Attempts to forage.
    # @return [Boolean] True if successful; false otherwise
    def forage
        if @current_harvestables > 0
            @current_harvestables -= 1
            @drops[harvestable_item_entity_type] -= 1
            return true
        end
        false
    end
end
