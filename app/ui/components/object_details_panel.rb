require 'app/objects/entities/persons/dwarf_person_entity'
require 'app/objects/entities/persons/goblin_person_entity'
require 'app/objects/entities/persons/person_entity'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/apple_tree_tile'
require 'app/objects/environment/tiles/berry_bush_tile'
require 'app/objects/environment/tiles/tile'
require 'app/ui/hud'
require 'app/modules/has_display_tags_module'
require 'app/modules/has_functional_descriptors_module'
require 'app/modules/other_modules'
require 'app/modules/skill_modules'
require 'app/utils/string_utils'

class ObjectDetailsPanelTab
    SELECTED_COLOR = {
        r: 0,
        g: 255,
        b: 255
    }

    MAX_TEXT_LENGTH = 10

    attr_accessor :text, :underline_index, :hovered, :selected, :w, :h, :padding

    def initialize text, underline_index
        # function
        @text = text
        @underline_index = underline_index
        @hovered = false
        @selected = false

        # appearance
        @padding = 10
        @w = MAX_TEXT_LENGTH * 8 + @padding * 2
        @h = 16 + @padding * 2
    end
end

class ObjectDetailsPanel
    attr_accessor :selected_object, :tabs, :selected_tab,
                  :visible, :x, :y, :w, :h, :border_thickness, :padding

    def initialize args
        # function
        @selected_object = nil

        @tabs = []
        @selected_tab = nil

        # appearance
        @visible = false
        @x = args.grid.w - Hud::RIGHT_MARGIN
        @y = Hud::BOTTOM_MARGIN + 16 * 2
        @w = 320
        @h = 512
        @border_thickness = 1
        @padding = 16
    end

    def tick args
        # tabs
        @tabs.each_with_index do |tab, i|
            collision_box = {
                x: @x - @w - tab.w + 1,
                y: @y + @h - (i + 1) * tab.h + i,
                w: tab.w,
                h: tab.h - (i == 0 ? 0 : 1)
            }

            # hover
            tab.hovered = args.inputs.mouse.inside_rect? collision_box

            # select tab on alt key
            ch = tab.text[tab.underline_index].downcase

            alt = args.inputs.keyboard.alt
            code = args.inputs.keyboard.key_down? ch
            
            @selected_tab = tab if alt and code
        end

        # selected tile changed
        if @selected_object.is_a?(Tile)
            tile = args.state.map.grid[@selected_object.row_index][@selected_object.column_index]
            if tile != @selected_object
                @visible = false
                @selected_object = nil
                @tabs = []
                @selected_tab = nil
            end
        end

        # hide panel on escape key
        if args.inputs.keyboard.key_down.escape
            @visible = false
            @selected_object = nil
            @tabs = []
            @selected_tab = nil
        end
    end

    def draw args
        return if not visible

        # border
        args.outputs.primitives << {
            x: @x,
            y: @y,
            w: @w,
            h: @h,
            anchor_x: 1,
            anchor_y: 0,
            r: 255,
            g: 255,
            b: 255
        }.solid!

        # background
        args.outputs.primitives << {
            x: @x - @border_thickness,
            y: @y + border_thickness,
            w: @w - @border_thickness * 2,
            h: @h - @border_thickness * 2,
            anchor_x: 1,
            anchor_y: 0,
            r: 0,
            g: 0,
            b: 0
        }.solid!

        # tabs
        change_tabs = @selected_tab.nil?

        if not change_tabs
            loadout = [ 'Info' ]

            if @selected_object.is_a?(DwarfPersonEntity)
                loadout = [
                    'Profile',
                    'Inventory',
                    'Skills',
                    'Social',
                    'Needs'
                ]
            elsif @selected_object.is_a?(GoblinPersonEntity)
                loadout = [
                    'Profile',
                    'Inventory',
                    'Skills'
                ]
            end

            if @tabs.length != loadout.length
                change_tabs = true
            else
                @tabs.each_with_index do |tab, i|
                    if tab.text != loadout[i]
                        change_tabs = true
                        break
                    end
                end
            end
        end

        if change_tabs
            if @selected_object.is_a?(DwarfPersonEntity)
                @tabs = [
                    ObjectDetailsPanelTab.new('Profile', 0),
                    ObjectDetailsPanelTab.new('Inventory', 0),
                    ObjectDetailsPanelTab.new('Skills', 1),
                    ObjectDetailsPanelTab.new('Social', 1),
                    ObjectDetailsPanelTab.new('Needs', 0)
                ]
            elsif @selected_object.is_a?(GoblinPersonEntity)
                @tabs = [
                    ObjectDetailsPanelTab.new('Profile', 0),
                    ObjectDetailsPanelTab.new('Inventory', 0),
                    ObjectDetailsPanelTab.new('Skills', 1)
                ]
            else
                @tabs = [
                    ObjectDetailsPanelTab.new('Info', 0)
                ]
            end
            @selected_tab = @tabs[0]
        end

        @tabs.each_with_index do |tab, i|
            # border
            args.outputs.primitives << {
                x: @x - @w + 1,
                y: @y + @h - (i + 1) * tab.h + i,
                w: tab.w,
                h: tab.h - (i == 0 ? 0 : 1),
                anchor_x: 1,
                anchor_y: 0,
                r: 255,
                g: 255,
                b: 255
            }.solid!

            # background
            args.outputs.primitives << {
                x: @x - @w + 1 - @border_thickness,
                y: @y + @h - (i + 1) * tab.h + i + border_thickness,
                w: tab.w - @border_thickness * 2,
                h: tab.h - @border_thickness * 2,
                anchor_x: 1,
                anchor_y: 0,
                r: 0,
                g: 0,
                b: 0
            }.solid!

            highlight = (tab.hovered or tab == @selected_tab)

            # text
            args.outputs.primitives << {
                x: @x - @w + 1 - tab.w + tab.padding,
                y: @y + @h - (i + 1) * tab.h + i + tab.padding,
                anchor_x: 0,
                anchor_y: 0,
                text: tab.text,
                size_px: 16,
                r: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.r : 255,
                g: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.g : 255,
                b: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.b : 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!
            
            # underline
            args.outputs.primitives << {
                x: @x - @w + 1 - tab.w + tab.padding + tab.underline_index * 8,
                y: @y + @h - (i + 1) * tab.h + i + tab.padding,
                w: 8,
                h: 1,
                r: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.r : 255,
                g: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.g : 255,
                b: highlight ? ObjectDetailsPanelTab::SELECTED_COLOR.b : 255
            }.solid!
        end
        
        if @selected_tab == @tabs[0]
            # title
            title = ''
            title = titleize(@selected_object.name) if @selected_object
            title += ' (' + @selected_object.count.to_s + ')' if @selected_object.is_a?(ItemEntity)
            title += ' (dead)' if @selected_object.is_a?(PersonEntity) and @selected_object.destroyed_or_dead?

            args.outputs.primitives << {
                x: @x - @w * 0.5,
                y: @y + @h - @border_thickness - padding,
                anchor_x: 0.5,
                anchor_y: 1,
                text: title,
                size_px: 21,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            # details
            details = ''
            if @selected_object
                if @selected_object.is_a?(HasDisplayTags)
                    tags = @selected_object.display_tags
                    details += tags.join(' ')
                    details += "\n" if not tags.empty?
                end
                
                details += "\n" + @selected_object.description.dup + "\n"
                
                if @selected_object.is_a?(HasFunctionalDescriptors)
                    descriptors = @selected_object.functional_descriptors
                    details += "\n" if not descriptors.empty?
                    details += descriptors.join("\n")
                end
            end

            max_character_length = (@w - @border_thickness * 2 - padding * 2) / 8
            split = details ? String.wrapped_lines(details, max_character_length) : []

            args.outputs.primitives << split.map_with_index do |str, i|
            {
                x: @x - @w + padding,
                y: @y + @h - @border_thickness - padding - 26 - 16 - 8,
                anchor_x: 0,
                anchor_y: i,
                text: str,
                size_px: 16,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!
            end

            if @selected_object.is_a?(HasDisplayTags)
                x_shift = @x - @w + padding

                @selected_object.display_tags.each do |tag|
                    args.outputs.primitives << {
                        x: x_shift,
                        y: @y + @h - @border_thickness - padding - 26 - 16 - 8 - 2,
                        w: tag.to_s.length * 8,
                        h: 1,
                        r: 255,
                        g: 255,
                        b: 255
                    }.solid!

                    x_shift += (tag.to_s.length + 1) * 8
                end
            end
        elsif @selected_tab.text == 'Inventory'
            # title
            args.outputs.primitives << {
                x: @x - @w * 0.5,
                y: @y + @h - @border_thickness - padding,
                anchor_x: 0.5,
                anchor_y: 1,
                text: 'Inventory',
                size_px: 21,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            lines = []

            # items
            @selected_object.inventory.each_with_index do |item, i|
                index = (i + 1).to_s + '. '
                item_name = titleize(item.name)
                item_weight = ' (' + item.weight.to_s + ' lbs.)'
                item_count = ' x' + item.count.to_s
                lines << index + item_name + item_weight + item_count
            end

            # carrying capacity
            current = @selected_object.carrying_capacity.to_s
            total = @selected_object.max_carrying_capacity.to_s
            lines << nil if not lines.empty?
            lines << 'Carrying capacity: ' + current + '/' + total

            # description
            args.outputs.primitives << lines.map_with_index do |str, i|
            {
                x: @x - @w + @padding,
                y: @y + @h - @border_thickness - padding - 26 - 16 - 8,
                anchor_x: 0,
                anchor_y: i,
                text: str,
                size_px: 16,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!
            end
        elsif @selected_tab.text == 'Skills'
            # title
            args.outputs.primitives << {
                x: @x - @w * 0.5,
                y: @y + @h - @border_thickness - padding,
                anchor_x: 0.5,
                anchor_y: 1,
                text: 'Skills',
                size_px: 21,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            # skills
            skills = []
            skills << [ 'Melee', @selected_object.melee_experience_points.floor ] if @selected_object.is_a?(HasMeleeSkill)
            skills << [ 'Archery', @selected_object.archery_experience_points.floor ] if @selected_object.is_a?(HasMeleeSkill)
            skills << [ 'Woodcutting', @selected_object.woodcutting_experience_points.floor ] if @selected_object.is_a?(HasWoodcuttingSkill)
            skills << [ 'Mining', @selected_object.mining_experience_points.floor ] if @selected_object.is_a?(HasMiningSkill)
            skills << [ 'Building', @selected_object.building_experience_points.floor ] if @selected_object.is_a?(HasBuildingSkill)
            skills << [ 'Planting', @selected_object.planting_experience_points.floor ] if @selected_object.is_a?(HasPlantingSkill)
            skills << [ 'Crafting', @selected_object.crafting_experience_points.floor ] if @selected_object.is_a?(HasCraftingSkill)

            max_character_length = (@w - @border_thickness * 2 - padding * 2) / 8 + 1

            # description
            skills.map_with_index do |skill, i|
                level = ((skill[1] / 100).floor + 1).to_s
                level += ' ' if level.length == 1
                level = ' Lv. ' + level

                current = (skill[1] % 100).to_s
                total = 100.to_s
                experience = ' (' + current + '/' + total
                experience += ' ' if current.length == 1
                experience += ' exp.)'

                line = skill[0] + level + experience
                spaces = ' ' * (max_character_length - line.length)
                line = skill[0] + spaces + level + experience

                args.outputs.primitives << {
                    x: @x - @w + @padding,
                    y: @y + @h - @border_thickness - padding - 26 - 16 - 8,
                    anchor_x: 0,
                    anchor_y: i,
                    text: line,
                    size_px: 16,
                    r: 255,
                    g: 255,
                    b: 255,
                    font: 'fonts/departure-mono-reg.otf'
                }.label!
            end
        elsif @selected_tab.text == 'Social'
            # title
            args.outputs.primitives << {
                x: @x - @w * 0.5,
                y: @y + @h - @border_thickness - padding,
                anchor_x: 0.5,
                anchor_y: 1,
                text: 'Social',
                size_px: 21,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            max_character_length = (@w - @border_thickness * 2 - padding * 2) / 8 + 1

            # description
            @selected_object.relationships.each_with_index do |(key, value), i|
                status = 'Acquaintance'
                status = 'Friend' if value >= 50
                status = 'Best Friend' if value >= 100
                
                line = key.name + status
                spaces = ' ' * (max_character_length - line.length)
                line = key.name + spaces + status

                args.outputs.primitives << {
                    x: @x - @w + @padding,
                    y: @y + @h - @border_thickness - padding - 26 - 16 - 8,
                    anchor_x: 0,
                    anchor_y: i,
                    text: line,
                    size_px: 16,
                    r: 255,
                    g: 255,
                    b: 255,
                    font: 'fonts/departure-mono-reg.otf'
                }.label!
            end
        elsif @selected_tab.text == 'Needs'
            # title
            args.outputs.primitives << {
                x: @x - @w * 0.5,
                y: @y + @h - @border_thickness - padding,
                anchor_x: 0.5,
                anchor_y: 1,
                text: 'Needs',
                size_px: 21,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!

            # needs
            needs = [
                [
                    'Hunger',
                    @selected_object.hunger_status,
                    @selected_object.hunger,
                    @selected_object.max_hunger
                ],
                [
                    'Sleep',
                    @selected_object.sleep_status,
                    @selected_object.sleep,
                    @selected_object.max_sleep
                ],
                [
                    'Fun',
                    @selected_object.fun_status,
                    @selected_object.fun,
                    @selected_object.max_fun
                ]
            ]

            max_character_length = (@w - @border_thickness * 2 - padding * 2) / 8 + 1

            # description
            needs.each_with_index do |need, i|
                line = need[0] + (' ' * (12 - need[0].length)) + need[1]
                value = need[2].to_s + '/' + need[3].to_s
                spaces = ' ' * (max_character_length - line.length - value.length)
                line += spaces + value

                args.outputs.primitives << {
                    x: @x - @w + @padding,
                    y: @y + @h - @border_thickness - padding - 26 - 16 - 8,
                    anchor_x: 0,
                    anchor_y: i,
                    text: line,
                    size_px: 16,
                    r: 255,
                    g: 255,
                    b: 255,
                    font: 'fonts/departure-mono-reg.otf'
                }.label!
            end
        end
    end

    def on_left_mouse_click args
        return if args.state.hud.selector.enabled
        return if args.inputs.mouse.inside_rect? args.state.hud.task_bar
        return if args.inputs.mouse.inside_rect? args.state.hud.tasks_panel and args.state.hud.tasks_panel.visible
        
        if @visible
            collision_box = {
                x: @x - @w,
                y: @y,
                w: @w,
                h: @h
            }

            return if args.inputs.mouse.inside_rect? collision_box

            # tabs
            flag = false

            @tabs.each_with_index do |tab, i|
                # select tab on mouse click
                collision_box = {
                    x: @x - @w - tab.w + 1,
                    y: @y + @h - (i + 1) * tab.h + i,
                    w: tab.w,
                    h: tab.h - (i == 0 ? 0 : 1)
                }

                if args.inputs.mouse.inside_rect? collision_box
                    @selected_tab = tab
                    flag = true
                end
            end

            return if flag

            if args.state.hud.hovered_objects.empty?
                @visible = false
                @selected_object = nil
                @tabs = []
                @selected_tab = nil
            else
                length = args.state.hud.hovered_objects.length
                i = args.state.hud.hovered_objects.index(@selected_object)
                i = i.nil? ? (length == 1 ? 0 : 1) : (i + 1) % length
                @selected_object = args.state.hud.hovered_objects[i]
            end
        elsif not args.state.hud.hovered_objects.empty?
            @visible = true
            i = args.state.hud.hovered_objects.length == 1 ? 0 : 1
            @selected_object = args.state.hud.hovered_objects[i]
        end
    end
end
