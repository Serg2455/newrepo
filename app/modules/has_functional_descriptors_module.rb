# Allows class instances to have functional descriptors for display purposes.
# E.g. wall tiles have the 'Movement difficulty: Impassable' descriptor.
module HasFunctionalDescriptors
    # Gets functional descriptors based on class inheritance and includes.
    def functional_descriptors
        descriptors = []

        # Gets functional descriptors (if any)
        FD = FunctionalDescriptor

        descriptors << FD.new(FD::MOVEMENT_DIFFICULTY, self) if is_a?(Tile)
        descriptors << FD.new(FD::HARVESTABLES, self) if is_a?(Forageable)
        descriptors << FD.new(FD::GROWTH_RATE, self) if is_a?(Forageable)
        descriptors << FD.new(FD::HIT_POINTS, self) if is_a?(HasHitPoints)
        descriptors << FD.new(FD::CARRYING_CAPACITY, self) if is_a?(HasInventory)
        descriptors << FD.new(FD::TASKS, self) if
            is_a?(CanPerformTasks) and
            not (is_a?(HasHitPoints) and self.destroyed_or_dead?)
        descriptors << FD.new(FD::REQUIRED_RESOURCES, self) if
            self.is_a?(Tile) and
            self.associated_tabs.key?('Build') and
            not self.has_required_resources?
        descriptors << FD.new(FD::REQUIRED_RESOURCES, self) if
            self.is_a?(Tile) and
            self.associated_tabs.key?('Craft') and  # added for crafting 
            not self.has_required_resources?

        return descriptors
    end

    # A functional descriptor structure for display purposes.
    # E.g. wall tiles have the 'Movement difficulty: Impassable' descriptor.
    # @attr [Integer] type - The display tag type
    # @attr [Object] it - The tagged object ("tag, you're it")
    class FunctionalDescriptor
        # Defines functional descriptor types
        MOVEMENT_DIFFICULTY = 0
        HIT_POINTS = 1
        CARRYING_CAPACITY = 2
        TASKS = 3
        HARVESTABLES = 4
        GROWTH_RATE = 5
        REQUIRED_RESOURCES = 6

        attr_accessor :type, :it

        # Default constructor.
        # @param [Integer] type - The functional descriptor type
        # @param [Object] it - The tagged object ("tag, you're it")
        # @return [void]
        def initialize type, it
            @type = type
            @it = it
        end

        # Gets string representation.
        # @return [String] The string representation
        def to_s
            # Stringifies functional descriptors
            if @type == MOVEMENT_DIFFICULTY
                item = 'Movement difficulty'
                return "#{item}: Impassable" if @it.wall?
                return "#{item}: #{sprintf('%.2f', @it.movement_difficulty)}"
            end

            if @type == HIT_POINTS
                item = 'Hit points'
                current = @it.hit_points.ceil.to_s
                maximum = @it.total_hit_points.to_s
                value = "#{current}/#{maximum}"
                return "#{item}: #{value}"
            end

            if @type == CARRYING_CAPACITY
                item = 'Carrying capacity'
                current = @it.carrying_capacity.ceil.to_s
                maximum = @it.max_carrying_capacity.to_s
                value = "#{current}/#{maximum}"
                return "#{item}: #{value}"
            end

            if @type == TASKS
                item = 'Current task'
                return "#{item}: Idling" if @it.task.nil?
                return "#{item}: #{@it.task.to_s}"
            end

            if @type == HARVESTABLES
                item = 'Harvestables'
                current = @it.current_harvestables.to_s
                maximum = @it.max_harvestables.to_s
                value = "#{current}/#{maximum}"
                return "#{item}: #{value}"
            end

            if @type == GROWTH_RATE
                item = 'Growth rate'
                numerator = FPS * Time::MINUTES_PER_HOUR * Time::HOURS_PER_DAY
                denominator = @it.spawn_timer_target
                value = "#{(numerator / denominator).floor.to_s}/day"
                return "#{item}: #{value}"
            end

            if @type == REQUIRED_RESOURCES
                item = 'Missing resources'
                values = @it.missing_resources.map do |item_class_type, count|
                    "- #{item_class_type.new.name} x#{count}"
                end
                return "#{item}:\n#{values.join("\n")}"
            end

            return nil # NOTE: This should never happen
        end
    end
end
