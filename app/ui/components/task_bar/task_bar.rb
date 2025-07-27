require 'app/objects/entities/persons/dwarf_person_entity'
require 'app/objects/environment/tiles/apple_tree_tile'
require 'app/objects/environment/tiles/berry_bush_tile'
require 'app/objects/environment/tiles/fence_tile'
require 'app/objects/environment/tiles/tree_tile'
require 'app/objects/environment/tiles/craft_tile'
require 'app/objects/tasks/build_task'
require 'app/objects/tasks/chop_task'
require 'app/objects/tasks/cut_task'
require 'app/objects/tasks/demolish_task'
require 'app/objects/tasks/forage_task'
require 'app/objects/tasks/craft_task'
require 'app/modules/tile_modules'
require 'app/ui/components/task_bar/panels/zone_panel'

class TaskBarOption
    SELECTED_COLOR = {
        r: 0,
        g: 255,
        b: 255
    }

    attr_accessor :text, :underline_index, :selection_mode, :hovered, :selected

    def initialize text, underline_index, selection_mode=false
        @text = text
        @underline_index = underline_index
        @selection_mode = selection_mode
        @hovered = false
        @selected = false
    end
end

class TaskBar
    attr_accessor :x, :y, :w, :h, :border_thickness, :padding, :column_gap,
                  :options, :selected_option,
                  :time_control_labels, :time_control_column_gap
    
    def initialize args
        @x = 0
        @y = args.grid.h - 36
        @w = args.grid.w
        @h = 36
        @border_thickness = 1
        @padding = 10
        @column_gap = 16

        @options = [
            TaskBarOption.new('Log', 0),
            TaskBarOption.new('Tasks', 0),
            TaskBarOption.new('Chop', 0, true),
            TaskBarOption.new('Cut', 1, true),
            TaskBarOption.new('Mine', 0, true),
            TaskBarOption.new('Build', 0, true),
            TaskBarOption.new('Demolish', 0, true),
            TaskBarOption.new('Hunt', 0, true),
            TaskBarOption.new('Forage', 0, true),
            TaskBarOption.new('Zone', 0, true),
            TaskBarOption.new('Craft', 0, true)     # added for crafting
        ]

        @time_control_labels = [
            'TIME CONTROL',
            'Pause',
            '1x',
            '1.5x',
            '2x',
            '3x'
        ]

        @time_control_column_gap = 12
    end

    def tick args
        # options
        x_shift = @padding

        options.each_with_index do |option, i|
            # highlight option on hover
            collision_box = {
                x: x_shift - @column_gap / 2,
                y: @y,
                w: option.text.length * 8 + @column_gap,
                h: @h + @padding * 2
            }

            option.hovered = args.inputs.mouse.inside_rect? collision_box

            x_shift += option.text.length * 8 + @column_gap

            # select/deselect option on alt key
            ch = option.text[option.underline_index].downcase

            alt = args.inputs.keyboard.alt
            code = args.inputs.keyboard.key_down? ch
            
            if alt and code
                @selected_option = (option == @selected_option ? nil : option)
            end
        end

        # deselect option on escape key
        if args.inputs.keyboard.key_down.escape
            no_selection = args.state.hud.selector.start_position.nil?
            no_selection = false if args.state.hud.selector.selection_just_erased
            panel_down = !args.state.hud.object_details_panel.visible
            
            @selected_option = nil if no_selection and panel_down
        end

        # time control
        if args.inputs.keyboard.key_down.zero
            args.state.time_control = 0
        elsif args.inputs.keyboard.key_down.one
            args.state.time_control = 1
            args.state.previous_time_control = 1
        elsif args.inputs.keyboard.key_down.two
            args.state.time_control = 2
            args.state.previous_time_control = 2
        elsif args.inputs.keyboard.key_down.three
            args.state.time_control = 3
            args.state.previous_time_control = 3
        elsif args.inputs.keyboard.key_down.four
            args.state.time_control = 4
            args.state.previous_time_control = 4
        end

        if args.inputs.keyboard.key_down.space
            if args.state.time_control == 0
                args.state.time_control = args.state.previous_time_control 
            else
                args.state.time_control = 0
            end
        end

        ZonePanel.tick(args)
    end
    
    def draw args
        # border
        args.outputs.primitives << {
            x: @x,
            y: @y,
            w: @w,
            h: @border_thickness,
            r: 255,
            g: 255,
            b: 255
        }.solid!

        # background
        args.outputs.primitives << {
            x: @x,
            y: @y + @border_thickness,
            w: @w,
            h: @h - @border_thickness,
            r: 0,
            g: 0,
            b: 0
        }.solid!

        # options
        x_shift = @padding

        options.each_with_index do |option, i|
            highlight = (option.hovered or option == @selected_option)
            
            # text
            args.outputs.primitives << {
                x: x_shift,
                y: @y + @h - @padding,
                text: option.text,
                size_px: 16,
                r: highlight ? TaskBarOption::SELECTED_COLOR.r : 255,
                g: highlight ? TaskBarOption::SELECTED_COLOR.g : 255,
                b: highlight ? TaskBarOption::SELECTED_COLOR.b : 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!
            
            # underline
            args.outputs.primitives << {
                x: x_shift + option.underline_index * 8,
                y: @y + @padding,
                w: 8,
                h: 1,
                r: highlight ? TaskBarOption::SELECTED_COLOR.r : 255,
                g: highlight ? TaskBarOption::SELECTED_COLOR.g : 255,
                b: highlight ? TaskBarOption::SELECTED_COLOR.b : 255
            }.solid!

            x_shift += option.text.length * 8 + @column_gap
        end

        # time control
        x_shift = args.grid.w - @padding

        @time_control_labels.reverse.each_with_index do |label, i|
            r = 255
            g = 255
            b = 255

            collision_box = {
                x: x_shift - @time_control_column_gap / 2,
                y: @y,
                anchor_x: 1,
                w: label.length * 8 + @time_control_column_gap,
                h: 16 + @padding * 2
            }

            hovering = args.inputs.mouse.inside_rect? collision_box
            
            if i == @time_control_labels.length - 1
                r = 192
                g = 192
                b = 192
            elsif args.state.time_control == 4 - i or hovering
                r = TaskBarOption::SELECTED_COLOR.r
                g = TaskBarOption::SELECTED_COLOR.g
                b = TaskBarOption::SELECTED_COLOR.b
            end

            args.outputs.primitives << {
                x: x_shift,
                y: @y + @h - @padding,
                anchor_x: 1,
                text: label,
                size_px: 16,
                r: r,
                g: g,
                b: b,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            x_shift -= label.length * 8 + @time_control_column_gap
        end

        ZonePanel.draw(args)
    end

    def on_left_mouse_click args
        # options
        x_shift = @padding

        options.each_with_index do |option, i|
            # select/deselect option on mouse click
            collision_box = {
                x: x_shift - @column_gap / 2,
                y: @y,
                w: option.text.length * 8 + @column_gap,
                h: @h + @padding * 2
            }

            if args.inputs.mouse.inside_rect? collision_box
                @selected_option = (option == @selected_option ? nil : option)
            end

            x_shift += option.text.length * 8 + @column_gap
        end

        # time control
        x_shift = args.grid.w - @padding

        @time_control_labels.reverse.each_with_index do |label, i|
            collision_box = {
                x: x_shift - @time_control_column_gap / 2,
                y: @y,
                anchor_x: 1,
                w: label.length * 8 + @time_control_column_gap,
                h: 16 + @padding * 2
            }

            if args.inputs.mouse.inside_rect? collision_box
                args.state.time_control = 4 - i
                args.state.previous_time_control = 4 - i if 4 - i > 0
            end

            x_shift -= label.length * 8 + @time_control_column_gap
        end

        ZonePanel.on_left_mouse_click(args)
    end

    def self.h
        36
    end

    def make_selection args, start_row_index, end_row_index, start_column_index, end_column_index
        return if @selected_option.nil?

        ZonePanel.make_selection(
            args,
            start_row_index,
            end_row_index,
            start_column_index,
            end_column_index)

        if @selected_option.text == 'Chop'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if not tile.is_a?(TreeTile)
                    next if tile.tasked_with_class?(ChopTask)
                    
                    task = ChopTask.new(args, nil, tile)
                    
                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end

        if @selected_option.text == 'Cut'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if not tile.is_a?(IsFoliage)
                    next if tile.is_a?(TreeTile)
                    next if tile.tasked_with_class?(CutTask)
                    
                    task = CutTask.new(args, nil, tile)
                    
                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end

        # TODO: rewrite to allow for things besides fences to be built
        # TODO: unintuitive for fences; should change selection to only edges
        if @selected_option.text == 'Build'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if tile.wall?
                    next if tile.tasked_with_class?(BuildTask)

                    tile.change_to(args, FenceTile.new(
                        i,
                        j,
                        @associated_stockpile_type))
                    tile = args.state.map.grid[i][j]

                    task = BuildTask.new(args, nil, tile)
                    
                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end

        if @selected_option.text == 'Demolish'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if not tile.is_a?(FenceTile)

                    if tile.associated_tasks.key?(BuildTask)
                        tile.associated_tasks[BuildTask].each do |task, _|
                            tile.dissociate_task(task)

                            task.assignee.task = nil if task.assignee
                            task.complete = true
                        end
                    end

                    tile.associated_tasks[BuildTask] = {}

                    task = DemolishTask.new(args, nil, tile)

                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end

        if @selected_option.text == 'Forage'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if not tile.is_a?(Forageable)
                    next if tile.tasked_with_class?(ForageTask)

                    task = ForageTask.new(args, nil, tile)

                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end

        # added for crafting
        if @selected_option.text == 'Craft'
            for i in start_row_index..end_row_index
                for j in start_column_index..end_column_index
                    tile = args.state.map.grid[i][j]

                    next if tile.wall?
                    next if tile.tasked_with_class?(CraftTask)

                    tile.change_to(args, CraftTile.new(
                        i,
                        j,
                        @associated_stockpile_type))
                    tile = args.state.map.grid[i][j]

                    task = CraftTask.new(args, nil, tile)
                    
                    tile.associate_task(task)
                    args.state.task_manager.tasks << task
                end
            end
        end
    end

    def make_deselection args, start_row_index, end_row_index, start_column_index, end_column_index
        return if @selected_option.nil?

        ZonePanel.make_deselection(
            args,
            start_row_index,
            end_row_index,
            start_column_index,
            end_column_index)

        # deselect chop tasks
        if @selected_option.text == 'Chop'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(ChopTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(ChopTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end

        # deselect cut tasks
        if @selected_option.text == 'Cut'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(CutTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(CutTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end

        # Deselect build task. Sometimes doesn't work? Need to stress test this
        if @selected_option.text == 'Build'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(BuildTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(BuildTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end

        # Cancel demolish. I should think about make the three deselects into a generalized function
        if @selected_option.text == 'Demolish'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(DemolishTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(DemolishTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end

        # deselect forage tasks
        if @selected_option.text == 'Forage'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(ForageTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(ForageTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end

        # deselect craft tasks, added for crafting
        if @selected_option.text == 'Craft'
            # already assigned to entity
            for entity in args.state.entities
                next if not entity.is_a?(DwarfPersonEntity)

                task = entity.task

                next if task.nil?
                next if not task.is_a?(CraftTask)
                next if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index

                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                task.complete = true
                entity.task = nil
            end

            # in task manager
            args.state.task_manager.tasks.delete_if do |task|
                next false if not task.is_a?(CraftTask)
                next false if task.archived_goal.row_index < start_row_index or task.archived_goal.row_index > end_row_index
                next false if task.archived_goal.column_index < start_column_index or task.archived_goal.column_index > end_column_index
                
                # cancel task
                args.state.map.grid[task.archived_goal.row_index][task.archived_goal.column_index].dissociate_task(task)
                true
            end
        end
    end
end
