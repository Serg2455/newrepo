require 'app/objects/entities/persons/dwarf_person_entity'
require 'app/ui/hud'
require 'app/utils/color'
require 'app/utils/font'

class TasksPanel
    attr_accessor :visible,
                  :x,
                  :y,
                  :w,
                  :h,
                  :border_thickness,
                  :padding,
                  :task_column_headers,
                  :task_column_width

    def initialize args
        @visible = false
        @x = 0
        @y = args.grid.h - 36 - 112
        @w = args.grid.w
        @h = 112
        @border_thickness = 1
        @padding = 16

        @task_column_headers = [
            'Chop',
            'Mine',
            'Build',
            'Hunt',
            'Farm',
            'Haul',
            'Craft'     # added for crafting
        ]

        @task_column_width = @task_column_headers.map(&:length).max
        @task_column_headers = @task_column_headers.map do |header|
            (' ' * (@task_column_width - header.length)) + header
        end
    end

    def tick args
        @visible = (not args.state.hud.task_bar.selected_option.nil? and
                    args.state.hud.task_bar.selected_option.text == 'Tasks')
    end

    def draw args
        if visible
            _draw_bottom_border args
            _draw_background args
            _draw_table args
        end
    end

    def _draw_bottom_border args
        args.outputs.primitives << {
            x: @x,
            y: @y,
            w: @w,
            h: @border_thickness
        }.merge(Color::WHITE).solid!
    end

    def _draw_background args
        args.outputs.primitives << {
            x: @x,
            y: @y + @border_thickness,
            w: @w,
            h: @h - @border_thickness
        }.merge(Color::BLACK).solid!
    end

    def _draw_table args
        args.outputs.primitives << {
            x: @x + @padding,
            y: @y + @h - @padding,
            text: '#  NAME' + (' ' * 15) + @task_column_headers.join(' ')
        }.merge(Color::WHITE).merge(DEPARTURE_MONO_FONT).merge(FONT_SIZE_BODY).label!
        
        dwarves = args.state.entities.select { |entity| entity.is_a?(DwarfPersonEntity) }
        dwarves = dwarves.sort_by { |dwarf| dwarf.name }

        args.outputs.primitives << dwarves.map_with_index do |dwarf, i|
        {
            x: @x + @padding,
            y: @y + @h - @padding - FONT_SIZE_BODY.size_px * 2.5,
            anchor_y: i,
            text: (i + 1).to_s + '. ' + dwarf.name
        }.merge(Color::WHITE).merge(DEPARTURE_MONO_FONT).merge(FONT_SIZE_BODY).label!
        end

        x_start = @x + @padding - 1
        y_start = @y + @h - @padding - FONT_SIZE_BODY.size_px * 2.5 + 1

        dwarves.map_with_index do |dwarf, i|
            @task_column_headers.map_with_index do |header, j|
                x_shift = FONT_SIZE_BODY.size_px / 2
                x_shift *= (25 + (@task_column_width + 1) * j)
                y_shift = -FONT_SIZE_BODY.size_px * i

                collision_box = {
                    x: x_start + x_shift,
                    y: y_start + y_shift,
                    w: FONT_SIZE_BODY.size_px - 2,
                    h: FONT_SIZE_BODY.size_px - 2
                }

                color = Color::WHITE
                color = Color::CYAN if args.inputs.mouse.inside_rect? collision_box

                args.outputs.primitives << collision_box.merge(color).border!

                next if not dwarf.can_perform header

                args.outputs.primitives << {
                    x: x_start + x_shift + (FONT_SIZE_BODY.size_px - 2) / 2,
                    y: y_start + y_shift + (FONT_SIZE_BODY.size_px - 2) / 2 + 2,
                    anchor_x: 0.5,
                    anchor_y: 0.5,
                    text: 'x',
                    size_px: 23
                }.merge(color).merge(DEPARTURE_MONO_FONT).label!
            end
        end
    end

    def on_left_mouse_click args
        return if not visible

        dwarves = args.state.entities.select { |entity| entity.is_a?(DwarfPersonEntity) }
        dwarves = dwarves.sort_by { |dwarf| dwarf.name }

        x_start = @x + @padding - 1
        y_start = @y + @h - @padding - FONT_SIZE_BODY.size_px * 2.5 + 1

        dwarves.map_with_index do |dwarf, i|
            @task_column_headers.map_with_index do |header, j|
                x_shift = FONT_SIZE_BODY.size_px / 2
                x_shift *= (25 + (@task_column_width + 1) * j)
                y_shift = -FONT_SIZE_BODY.size_px * i

                collision_box = {
                    x: x_start + x_shift,
                    y: y_start + y_shift,
                    w: FONT_SIZE_BODY.size_px - 2,
                    h: FONT_SIZE_BODY.size_px - 2
                }

                if args.inputs.mouse.inside_rect? collision_box
                    if dwarf.can_perform header
                        dwarf.disable_perform header
                    else
                        dwarf.enable_perform header
                    end
                end
            end
        end
    end
end
