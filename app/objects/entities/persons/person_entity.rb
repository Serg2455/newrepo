require 'app/algorithms/shadowcasting/shadowcasting'
require 'app/modules/other_modules'
require 'app/modules/skill_modules'
require 'app/objects/entities/entity'
require 'app/objects/tasks/pick_up_task'
require 'app/objects/tasks/wander_task'
require 'app/utils/time_control'
require 'app/utils/utils'

# A person abstract.
# @attr [String] species - The entity species
# @attr [String] sex - The entity sex
# @attr [Array[Tile]] visible_tiles - List of tiles visible to the entity
# @attr [Task] task - The assigned task
# @attr [Integer] idle_timer - The idle timer
# @attr [Float] idle_timer_target - The randomized idle timer target
class PersonEntity < Entity
    include HasHitPoints
    include HasInventory
    include CanPerformTasks

    IDLE_TIMER_MIN_RANGE = (FPS * 2 / Entity.action_timer_target).floor
    IDLE_TIMER_MAX_RANGE = (FPS * 5 / Entity.action_timer_target).floor

    attr_accessor :species, :sex, :visible_tiles, :task, :idle_timer,
                  :idle_timer_target

    # Default constructor.
    # @param [String] name - The entity name
    # @param [String] description - The entity description
    # @param [String] species - The entity species
    # @param [String] sex - The entity sex
    # @param [Character] ascii - The ascii character representation
    # @param [Color] color - The ascii character representation text color
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @return [void]
    def initialize name, description, species, sex, ascii, color, row_index,
                   column_index
        @species = species
        @sex = sex
        @visible_tiles = []
        @task = nil
        @idle_timer = 0
        @idle_timer_target =
            Numeric.rand(IDLE_TIMER_MIN_RANGE...IDLE_TIMER_MAX_RANGE)

        super name, description, ascii, color, row_index, column_index
    end
    
    # Updates the entity.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If dead
        if self.destroyed_or_dead?
            # Unassigns task (if any)
            self.unassign_task(args) if @task
        end

        super
    end

    # Takes an action.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def act args
        # Resets visible tiles
        @visible_tiles = []

        # Does not take an action if dead
        return if self.destroyed_or_dead?

        # Calculates FOV
        if not args.state.map.grid.nil?
            # Calculates visible tiles
            Shadowcasting.compute_fov(args, self)
            # Sets visible tiles to visible for fog of war display purposes
            @visible_tiles.each { |tile| tile.in_fov = true }
        end

        # If there is no task assigned
        if @task.nil?
            # Increments idle timer
            @idle_timer += 1
            # If idle timer meets target
            if @idle_timer >= TimeControl.adjust(args, @idle_timer_target)
                # Resets timer
                @idle_timer = 0
                # Randomizes target
                @idle_timer_target =
                    Numeric.rand(IDLE_TIMER_MIN_RANGE...IDLE_TIMER_MAX_RANGE)
                # Assigns wander task
                @task = WanderTask.new(args, self)
            end
        else
            # Performs the task if performable; unassigns the task otherwise
            (can_perform(@task.name) or @task.override_can_perform) ?
                @task.tick(args) : self.unassign_task(args)
        end

        super
    end

    # Unassigns task from entity.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def unassign_task args
        @task.assignee = nil
        @task.goal = @task.archived_goal.dup
        @task.item_entity.dissociate_task(@task) if @task.is_a?(PickUpTask)
        args.state.task_manager.tasks << @task if not @task.is_a?(WanderTask) and
                                                  not @task.is_a?(PickUpTask)
        @task = nil
    end
end
