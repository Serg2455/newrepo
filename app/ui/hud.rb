require 'app/utils/utils'

require_relative 'components/task_bar/task_bar'
require_relative 'components/time_info_label'
require_relative 'components/tile_info_label'
require_relative 'components/camera_zoom_label'
require_relative 'components/object_details_panel'
require_relative 'components/task_bar/panels/tasks_panel'

class Selector
    attr_accessor :enabled, :selecting, :start_position, :end_position,
                  :border_thickness, :selection_just_erased

    def deselecting
        return !selecting
    end

    def initialize
        @enabled = false
        @selecting = false
        @start_position = nil
        @end_position = nil
        @border_thickness = 1
        @selection_just_erased = false
    end

    def tick args
        # reset
        @enabled = false
        @selection_just_erased = false

        if not args.state.hud.task_bar.selected_option.nil?
            if args.state.hud.task_bar.selected_option.selection_mode
                @enabled = true
            end
        end

        if not enabled
            @start_position = nil
            @end_position = nil

            return
        end

        # end selection on mouse release
        if (@selecting and args.inputs.mouse.button_left) or (deselecting and args.inputs.mouse.button_right)
            @end_position = {
                row_index: mouse_row_index(args),
                column_index: mouse_column_index(args)
            }
        elsif !start_position.nil? and !@end_position.nil?
            start_row_index = [ @start_position.row_index, @end_position.row_index ].min
            end_row_index = [ @start_position.row_index, @end_position.row_index ].max

            start_column_index = [ @start_position.column_index, @end_position.column_index ].min
            end_column_index = [ @start_position.column_index, @end_position.column_index ].max

            args.state.hud.task_bar.make_selection(args, start_row_index, end_row_index, start_column_index, end_column_index) if selecting
            args.state.hud.task_bar.make_deselection(args, start_row_index, end_row_index, start_column_index, end_column_index) if deselecting

            @start_position = nil
            @end_position = nil
        end

        # erase selection on escape key
        if args.inputs.keyboard.key_down.escape
            if not args.state.hud.object_details_panel.visible
                if not @start_position.nil?
                    @start_position = nil
                    @end_position = nil
                    @selection_just_erased = true
                end
            end
        end
    end

    def draw args
        return if @start_position.nil? or @end_position.nil?

        x = args.state.map.global_x(args) + [ @start_position.column_index, @end_position.column_index ].min * TILE_SIZE * args.state.camera.zoom
        y = args.state.map.global_y(args) - [ @start_position.row_index, @end_position.row_index ].max * TILE_SIZE * args.state.camera.zoom - TILE_SIZE * args.state.camera.zoom
        w = (@start_position.column_index - @end_position.column_index).abs * TILE_SIZE * args.state.camera.zoom + TILE_SIZE * args.state.camera.zoom
        h = (@start_position.row_index - @end_position.row_index).abs * TILE_SIZE * args.state.camera.zoom + TILE_SIZE * args.state.camera.zoom

        # top border
        args.outputs.primitives << {
            x: x,
            y: y + h - @border_thickness,
            w: w,
            h: @border_thickness,
            r: 0,
            g: 255,
            b: 255
        }.solid!

        # bottom border
        args.outputs.primitives << {
            x: x,
            y: y,
            w: w,
            h: @border_thickness,
            r: 0,
            g: 255,
            b: 255
        }.solid!

        # left border
        args.outputs.primitives << {
            x: x,
            y: y,
            w: @border_thickness,
            h: h,
            r: 0,
            g: 255,
            b: 255
        }.solid!

        # right border
        args.outputs.primitives << {
            x: x + w - @border_thickness,
            y: y,
            w: @border_thickness,
            h: h,
            r: 0,
            g: 255,
            b: 255
        }.solid!
    end

    def on_left_mouse_click args
        return if ZonePanel.mouse_hovering?(args)
        begin_selection args
        @selecting = true
    end

    def on_right_mouse_click args
        begin_selection args
        @selecting = false
    end

    def begin_selection args
        return if not enabled or args.state.hud.hovered_objects.empty?

        # begin selection on mouse hold
        @start_position = {
            row_index: mouse_row_index(args),
            column_index: mouse_column_index(args)
        }

        @end_position = nil
    end
end

class Hud
    LEFT_MARGIN = 16
    RIGHT_MARGIN = 16
    TOP_MARGIN = 16
    BOTTOM_MARGIN = 16

    attr_accessor :hovered_objects,
                  :selector,
                  :task_bar,
                  :time_info_label,
                  :tile_info_label,
                  :camera_zoom_label,
                  :object_details_panel,
                  :tasks_panel

    def initialize args
        # selection mode
        @selector = Selector.new

        # components
        @task_bar = TaskBar.new args
        @time_info_label = TimeInfoLabel.new
        @tile_info_label = TileInfoLabel.new
        @camera_zoom_label = CameraZoomLabel.new
        @object_details_panel = ObjectDetailsPanel.new args
        @tasks_panel = TasksPanel.new args
    end

    def tick args
        # sort hovered objects
        if @hovered_objects.length > 1
            first = [@hovered_objects.first]
            persons = (@hovered_objects[1..].select { |obj| obj.is_a?(PersonEntity) }).sort_by { |obj| obj.name }
            items = (@hovered_objects[1..].select { |obj| obj.is_a?(ItemEntity) }).sort_by { |obj| obj.name }
            @hovered_objects = first + persons + items
        end
    
        # selection mode
        @selector.tick args

        # components
        @task_bar.tick args
        @object_details_panel.tick args
        @tasks_panel.tick args

        # mouse click
        on_left_mouse_click args if args.inputs.mouse.click
        on_right_mouse_click args if args.inputs.mouse.key_down.right
    end

    def draw args
        # selection mode
        @selector.draw args

        # components
        @task_bar.draw args
        @time_info_label.draw args
        @tile_info_label.draw args
        @camera_zoom_label.draw args
        @object_details_panel.draw args
        @tasks_panel.draw args
    end

    def on_left_mouse_click args
        # selection mode
        @selector.on_left_mouse_click args

        # components
        @task_bar.on_left_mouse_click args
        @object_details_panel.on_left_mouse_click args
        @tasks_panel.on_left_mouse_click args
    end

    def on_right_mouse_click args
        # selection mode
        @selector.on_right_mouse_click args
    end
end
