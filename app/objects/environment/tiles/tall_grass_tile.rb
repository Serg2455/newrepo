require 'app/modules/other_modules'
require 'app/modules/tile_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/grass_tile'
require 'app/objects/environment/tiles/tile'
require 'app/utils/color'
require 'app/utils/debug'
require 'app/utils/time_control'
require 'app/utils/utils'

# A tall grass tile object.
class TallGrassTile < Tile
    include IsFoliage
    include HasHitPoints

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        @hit_points = 10
        @total_hit_points = 10
        @cut = false
        super('tall grass',
              'Dense, overgrown grass that reaches up to the knees and '       \
              'rustles with movement.',
              '%',
              Color::GREEN,
              row_index,
              column_index,
              1.5,
              {},
              { 'Cut' => nil, 'Zone' => nil },
              associated_stockpile_type)
    end
end
