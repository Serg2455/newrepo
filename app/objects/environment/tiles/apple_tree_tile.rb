require 'app/modules/tile_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/tree_tile'
require 'app/utils/date_time/time'
require 'app/utils/color'
require 'app/utils/utils'

# An apple tree tile object.
class AppleTreeTile < TreeTile
    include Forageable

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        @harvestable_item_entity_type = AppleItemEntity
        @max_harvestables = 12
        @current_harvestables = (rand * @max_harvestables).ceil
        @spawn_timer = 0
        @spawn_timer_target = FPS * Time::MINUTES_PER_HOUR * Time::HOURS_PER_DAY

        super('apple tree',
              'A fruit tree with a wide canopy. It produces crisp, red apples.',
              Color::BROWN,
              row_index,
              column_index,
              {
                WoodItemEntity => 80,
                AppleItemEntity => @current_harvestables
              },
              { 'Chop' => nil, 'Forage' => nil, 'Zone' => nil },
              120,
              associated_stockpile_type)
    end

    # Updates apple tree tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        tick_forage(args)

        # Updates default color based on number of harvestables
        @default_color = Color::BROWN
        @default_color = Color::RED if @current_harvestables > 0

        super
    end
end
