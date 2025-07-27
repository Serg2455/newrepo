require 'app/modules/other_modules'
require 'app/modules/tile_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/tile'
require 'app/utils/date_time/time'
require 'app/utils/color'
require 'app/utils/utils'

# A berry bush tile object.
class BerryBushTile < Tile
    include HasHitPoints
    include IsFoliage
    include Forageable

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        @hit_points = 25
        @total_hit_points = 25

        @harvestable_item_entity_type = BerryItemEntity
        @max_harvestables = 64
        @current_harvestables = (rand * @max_harvestables).ceil
        @spawn_timer = 0
        @spawn_timer_target =
            (FPS * Time::MINUTES_PER_HOUR * Time::HOURS_PER_DAY) / 5
        
        super('berry bush',
              'A small bush with thorny branches. It produces sweet red '      \
              'berries.',
              '%',
              Color::GREEN,
              row_index,
              column_index,
              1.5,
              {
                BerryItemEntity => @current_harvestables
              },
              { 'Cut' => nil, 'Forage' => nil, 'Zone' => nil },
              associated_stockpile_type)
    end

    # Updates berry bush tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        tick_forage(args)

        # Updates default color based on number of harvestables
        @default_color = Color::GREEN
        @default_color = Color::RED if @current_harvestables > 0

        super
    end
end
