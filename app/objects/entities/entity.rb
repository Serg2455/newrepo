require 'app/modules/has_display_tags_module'
require 'app/modules/has_functional_descriptors_module'
require 'app/utils/color'
require 'app/utils/font'
require 'app/utils/time_control'
require 'app/utils/utils'

# An entity abstract.
# @attr [String] name - The entity name
# @attr [String] description - The entity description
# @attr [Character] ascii - The ascii character representation
# @attr [Color] color - The ascii character representation text color 
# @attr [Integer] row_index - The row index
# @attr [Integer] column_index - The column index
# @attr [Hash] velocity - The velocity (use velocity.x, velocity.y)
# @attr [Dictionary[Class, Dictionary[Task, void]]] associated_tasks - Tasks
class Entity
    include HasDisplayTags
    include HasFunctionalDescriptors

    class << self
        attr_accessor :action_timer, :action_timer_target, :slow_turn
    end

    @action_timer = 0
    @action_timer_target = FPS
    @slow_turn = false

    attr_accessor :name,
                  :description,
                  :ascii,
                  :color,
                  :column_index,
                  :row_index,
                  :velocity,
                  :associated_tasks

    # Default constructor.
    # @param [String] name - The entity name
    # @param [String] description - The entity description
    # @param [Character] ascii - The ascii character representation
    # @param [Color] color - The ascii character representation text color 
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @return [void]
    def initialize name, description, ascii, color, row_index, column_index
        @name = name
        @description = description
        @ascii = ascii
        @color = color
        @row_index = row_index
        @column_index = column_index
        @velocity = { x: 0, y: 0 }
        @associated_tasks = {}
    end

    # Updates the entity.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If mouse hovered
        if args.inputs.mouse.inside_rect?({
            x: global_x(args),
            y: global_y(args),
            w: global_w(args),
            h: global_h(args)
        })
            # Adds entity to hovered objects list
            args.state.hud.hovered_objects << self
        end
    end

    # Takes an action.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def act args
        # Moves entity
        @row_index += @velocity.y
        @column_index += @velocity.x

        # Resets velocity
        @velocity = { x: 0, y: 0 }
    end
    
    # Draws the entity.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw args
        # If selected
        if self == args.state.hud.object_details_panel.selected_object
            # Draw border
            args.outputs[:scene].primitives << {
                x: self.local_x(args),
                y: self.local_y(args),
                w: self.local_w,
                h: self.local_h
            }.merge(Color::WHITE).solid!

            # Draw background
            args.outputs[:scene].primitives << {
                x: self.local_x(args) + 1,
                y: self.local_y(args) + 1,
                w: self.local_w - 2,
                h: self.local_h - 2
            }.merge(Color::BLACK).solid!
        else
            # Draw background
            args.outputs[:scene].primitives << {
                x: self.local_x(args),
                y: self.local_y(args),
                w: self.local_w,
                h: self.local_h
            }.merge(Color::BLACK).solid!
        end

        # Draws ASCII character representation
        args.outputs[:scene].primitives << {
            x: self.local_x(args) + self.local_w / 2,
            y: self.local_y(args) + self.local_h / 2,
            anchor_x: 0.5,
            anchor_y: 0.5,
            text: @ascii
        }.merge(@color).merge(DEPARTURE_MONO_FONT).label!
    end

    # Gets global entity x position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global entity x position
    def global_x args
        args.state.viewport.x + self.local_x(args) * args.state.camera.zoom
    end

    # Gets global entity y position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global entity y position
    def global_y args
        args.state.viewport.y + self.local_y(args) * args.state.camera.zoom
    end

    # Gets global entity width.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global entity width
    def global_w args
        self.local_w * args.state.camera.zoom
    end

    # Gets global entity height.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global entity height
    def global_h args
        self.global_w(args)
    end

    # Gets local entity x position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The local entity x position
    def local_x args
        args.state.map.local_x + @column_index * TILE_SIZE
    end

    # Gets local entity y position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The local entity y position
    def local_y args
        args.state.map.local_y + args.state.map.local_h - (@row_index + 1) * TILE_SIZE
    end

    # Gets local entity width.
    # @return [Float] The local entity width
    def local_w
        TILE_SIZE
    end

    # Gets local entity height.
    # @return [Float] The local entity height
    def local_h
        self.local_w
    end

    # Determines whether the entity has an associated task of the given task
    # class type.
    # @param [Class] task_class_type - The class type of the associated task
    # @return [Boolean] True if an associated task exists; false otherwise
    def tasked_with_class?(task_class_type)
        return (@associated_tasks.key?(task_class_type) and
               not @associated_tasks[task_class_type].empty?)
    end

    # Associates a task with the entity.
    # @ param [Task] task_to_associate_with - The task to associate
    # @ return [void]
    def associate_task(task_to_associate_with)
        # Indexes Task if not indexed yet
        @associated_tasks[Task] = {} if not @associated_tasks.key?(Task)
        # Associates task with tile, broadly
        @associated_tasks[Task][task_to_associate_with] = nil

        task_class_type = task_to_associate_with.class

        # If task class type not indexed yet
        if not @associated_tasks.key?(task_class_type)
            # Indexes task class type
            @associated_tasks[task_class_type] = {}
        end

        # Associates task with tile and task class type
        @associated_tasks[task_class_type][task_to_associate_with] = nil
    end

    # Dissociates a task with the entity.
    # @param [Task] task_to_dissociate_with - The task to dissociate
    # @return [void]
    def dissociate_task(task_to_dissociate_with)
        # Indexes Task if not indexed yet
        @associated_tasks[Task] = {} if not @associated_tasks.key?(Task)
        # Dissociates task with tile, broadly
        @associated_tasks[Task].delete(task_to_dissociate_with)

        task_class_type = task_to_dissociate_with.class

        # If task class type not indexed yet
        if not @associated_tasks.key?(task_class_type)
            # Indexes task class type
            @associated_tasks[task_class_type] = {}
        end

        # Dissociates task with tile and task class type
        @associated_tasks[task_class_type].delete(task_to_dissociate_with)
    end
end
