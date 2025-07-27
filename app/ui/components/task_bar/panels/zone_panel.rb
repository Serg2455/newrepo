require 'app/enums/stockpile_type'
require 'app/ui/components/task_bar/task_bar'
require 'app/utils/color'
require 'app/utils/font'
require 'app/utils/string_utils'

# A zone panel card object. Attaches to a zone panel.
# @attr [Integer] index - The zone panel positional index
# @attr [Hash] metadata - The zone panel card metadata
class ZonePanelCard
    attr_accessor :index
    attr_accessor :metadata
    
    # Default constructor.
    # @param [Integer] index - The zone panel positional index
    # @param [Hash] metadata - The zone panel card metadata
    # @return [void]
    def initialize index, metadata
        @index = index
        @metadata = metadata
    end

    # Updates card.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
    end

    # Draws the zone panel card.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw args
        self.draw_background(args)
        self.draw_ascii(args)
        self.draw_title(args)
    end

    # Draws the zone panel card background.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw_background args
        return if not self.mouse_hovering?(args) and not self.selected?
        args.outputs.primitives << self.collision_box(args).merge(Color::WHITE)
                                                           .merge({ a: 16 })
                                                           .solid!
    end

    # Draws the zone panel card ascii character representation.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw_ascii args
        args.outputs.primitives << {
            x: self.x + ZonePanelCard.w / 2,
            y: ZonePanelCard.y(args) + ZonePanelCard.padding +
               ZonePanelCard.title_h + ZonePanelCard.ascii_h / 2,
            anchor_x: 0.5,
            anchor_y: 0.5,
            text: self.metadata[:ascii],
            size_px: 42
        }.merge(self.metadata[:ascii_color])
         .merge(DEPARTURE_MONO_FONT).label!
    end

    # Draws the zone panel card display name.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw_title args
        lines = word_wrap(self.metadata[:display_name], 12)
        
        lines.each_with_index do |line, index|
            args.outputs.primitives << {
                x: self.x + ZonePanelCard.w / 2,
                y: ZonePanelCard.y(args) + ZonePanelCard.padding -
                   index * FONT_SIZE_BODY.size_px +
                   lines.length * (FONT_SIZE_BODY.size_px / 2),
                anchor_x: 0.5,
                anchor_y: 0.5,
                text: line
            }.merge(Color::WHITE)
             .merge(DEPARTURE_MONO_FONT)
             .merge(FONT_SIZE_BODY).label!
        end
    end

    # Handles left mouse click event.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def on_left_mouse_click args
        ZonePanel.selected_card = self if self.mouse_hovering?(args)
    end

    # Makes a selection.
    # @param [Args] args - DragonRuby arguments
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_column_index - The end column index
    # @return [void]
    def make_selection args,
                       start_row_index,
                       end_row_index,
                       start_column_index,
                       end_column_index
        return self.make_deselection(
            args,
            start_row_index,
            end_row_index,
            start_column_index,
            end_column_index) if self.metadata[:reverse_selection]
        
        for i in start_row_index..end_row_index
            for j in start_column_index..end_column_index
                args.state.map.grid[i][j].associated_stockpile_type =
                    self.metadata[:associated_stockpile_type]
            end
        end
    end

    # Makes a deselection.
    # @param [Args] args - DragonRuby arguments
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_column_index - The end column index
    # @return [void]
    def make_deselection args,
                         start_row_index,
                         end_row_index,
                         start_column_index,
                         end_column_index
        for i in start_row_index..end_row_index
            for j in start_column_index..end_column_index
                args.state.map.grid[i][j].associated_stockpile_type = nil if
                    args.state.map.grid[i][j].associated_stockpile_type ==
                        self.metadata[:associated_stockpile_type]
            end
        end
    end

    # Determines whether the mouse is hovering over the zone panel card.
    # @param [Args] args - DragonRuby arguments
    # @return [Boolean] True if mouse hovering; false otherwise
    def mouse_hovering? args
        args.inputs.mouse.inside_rect?(self.collision_box(args))
    end

    # Gets the (local AND global) x-coordinate position.
    # @return [Float] The (local AND global) x-coordinate position
    def x
        ZonePanel.x + ZonePanel.padding +
            @index * (ZonePanelCard.w + ZonePanelCard.padding)
    end

    # Gets the (local AND global) y-coordinate position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The (local AND global) y-coordinate position
    def self.y args
        ZonePanel.y(args) + ZonePanel.padding
    end

    # Gets the (local AND global) width.
    # @return [Float] The (local AND global) width
    def self.w
        120
    end

    # Gets the (local AND global) height.
    # @return [Float] The (local AND global) height
    def self.h
        120
    end

    # Gets the padding width.
    # @return [Float] The padding width
    def self.padding
        16
    end

    # Gets the (local AND global) collision box.
    # @param [Args] args - DragonRuby arguments
    # @return [Hash] The (local AND global) collision box.
    def collision_box args
        {
            x: self.x,
            y: ZonePanelCard.y(args),
            w: ZonePanelCard.w,
            h: ZonePanelCard.h
        }
    end

    # Gets the (local AND global) height of the title.
    # @return [Float] The (local AND global) height of the title.
    def self.title_h
        40
    end

    # Gets the (local AND global) height of the ascii character representation.
    # @return [Float] The (local AND global) height of the ascii character representation.
    def self.ascii_h
        ZonePanelCard.h - ZonePanelCard.padding * 2 - ZonePanelCard.title_h
    end

    # Gets whether the zone panel card is selected
    # @return [Boolean] True if selected; false otherwise
    def selected?
        ZonePanel.selected_card == self
    end
end

# The zone panel static class. Appears when the Zone activity is selected.
# @attr [Hash] metadata - The zone panel metadata for building cards
# @attr [Array[ZonePanelCard]] cards - The attached zone panel cards
# @attr [ZonePanelCard]] selected_card - The selected zone panel card
class ZonePanel
    class << self
        attr_accessor :metadata, :cards, :selected_card
    end

    @metadata = {
        wood: {
            ascii: '=',
            ascii_color: Color::BROWN,
            display_name: 'Expand Wood Stockpile',
            associated_stockpile_type: StockpileType::WOOD,
            reverse_selection: false
        },
        clear_wood: {
            ascii: 'x',
            ascii_color: Color::BROWN,
            display_name: 'Clear Wood Stockpile',
            associated_stockpile_type: StockpileType::WOOD,
            reverse_selection: true
        },
        food: {
            ascii: 'a',
            ascii_color: Color::RED,
            display_name: 'Expand Food Stockpile',
            associated_stockpile_type: StockpileType::FOOD,
            reverse_selection: false
        },
        clear_food: {
            ascii: 'x',
            ascii_color: Color::RED,
            display_name: 'Clear Food Stockpile',
            associated_stockpile_type: StockpileType::FOOD,
            reverse_selection: true
        }
    }

    @cards = [
        ZonePanelCard.new(0, ZonePanel.metadata[:wood]),
        ZonePanelCard.new(1, ZonePanel.metadata[:clear_wood]),
        ZonePanelCard.new(2, ZonePanel.metadata[:food]),
        ZonePanelCard.new(3, ZonePanel.metadata[:clear_food])
    ]

    @selected_card = ZonePanel.cards[0] if ZonePanel.cards

    # Updates panel.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def self.tick args
        return if not ZonePanel.visible?(args)
        ZonePanel.cards.each { |card| card.tick(args) }
    end

    # Draws panel.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def self.draw args
        return if not ZonePanel.visible?(args)
        
        ZonePanel.draw_bottom_border(args)
        ZonePanel.draw_background(args)
        ZonePanel.cards.each { |card| card.draw(args) }
    end

    # Draws panel bottom border.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def self.draw_bottom_border args
        args.outputs.primitives << {
            x: ZonePanel.x,
            y: ZonePanel.y(args),
            w: ZonePanel.w(args),
            h: ZonePanel.border_thickness
        }.merge(Color::WHITE).solid!
    end

    # Draws panel background.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def self.draw_background args
        args.outputs.primitives << {
            x: ZonePanel.x,
            y: ZonePanel.y(args) + ZonePanel.border_thickness,
            w: ZonePanel.w(args),
            h: ZonePanel.h - ZonePanel.border_thickness
        }.merge(Color::BLACK).solid!
    end

    # Handles left mouse click event.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def self.on_left_mouse_click args
        return if not ZonePanel.visible?(args)
        ZonePanel.cards.each { |card| card.on_left_mouse_click(args) }
    end

    # Makes a selection.
    # @param [Args] args - DragonRuby arguments
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_column_index - The end column index
    # @return [void]
    def self.make_selection args,
                            start_row_index,
                            end_row_index,
                            start_column_index,
                            end_column_index
        return if not ZonePanel.visible?(args) or ZonePanel.selected_card.nil?
        ZonePanel.selected_card.make_selection(
            args,
            start_row_index,
            end_row_index,
            start_column_index,
            end_column_index)
    end

    # Makes a deselection.
    # @param [Args] args - DragonRuby arguments
    # @param [Integer] start_row_index - The start row index
    # @param [Integer] end_row_index - The end row index
    # @param [Integer] start_column_index - The start column index
    # @param [Integer] end_column_index - The end column index
    # @return [void]
    def self.make_deselection args,
                              start_row_index,
                              end_row_index,
                              start_column_index,
                              end_column_index
        return if not ZonePanel.visible?(args) or ZonePanel.selected_card.nil?
        ZonePanel.selected_card.make_deselection(
            args,
            start_row_index,
            end_row_index,
            start_column_index,
            end_column_index)
    end

    # Determines whether the mouse is hovering over the zone panel.
    # @param [Args] args - DragonRuby arguments
    # @return [Boolean] True if mouse hovering; false otherwise
    def self.mouse_hovering? args
        return false if not ZonePanel.visible?(args)
        ZonePanel.cards.each { |card| return true if card.mouse_hovering?(args) }
        args.inputs.mouse.inside_rect?(ZonePanel.collision_box(args))
    end

    # Determines whether zone panel is visible.
    # @param [Args] args - DragonRuby arguments
    # @return [Boolean] True if visible; false otherwise
    def self.visible? args
        not args.state.hud.task_bar.selected_option.nil? and
            args.state.hud.task_bar.selected_option.text == 'Zone'
    end

    # Gets (local AND global) x-coordinate position.
    # @return [Float] The (local AND global) x-coordinate position
    def self.x
        0
    end

    # Gets (local AND global) y-coordinate position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The (local AND global) y-coordinate position
    def self.y args
        args.grid.h - TaskBar.h - ZonePanel.h
    end

    # Gets the (local AND global) width.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The (local AND global) width
    def self.w args
        args.grid.w
    end

    # Gets the (local AND global) height.
    # @return [Float] The (local AND global) height
    def self.h
        ZonePanelCard.h + ZonePanel.padding * 2
    end

    # Gets the (local AND global) border thickness.
    # @return [Float] The (local AND global) border thickness
    def self.border_thickness
        1
    end

    # Gets the (local AND global) padding.
    # @return [Float] The (local AND global) padding
    def self.padding
        16
    end

    # Gets the (local AND global) collision box.
    # @param [Args] args - DragonRuby arguments
    # @return [Hash] The (local AND global) collision box.
    def self.collision_box args
        {
            x: ZonePanel.x,
            y: ZonePanel.y(args),
            w: ZonePanel.w(args),
            h: ZonePanel.h
        }
    end
end
