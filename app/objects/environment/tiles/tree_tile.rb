require 'app/modules/other_modules'
require 'app/modules/tile_modules'
require 'app/objects/environment/tiles/tile'

# A tree tile object.
class TreeTile < Tile
    include IsFoliage
    include HasHitPoints

    # Default constructor.
    # @param [String] name - The tile name
    # @param [String] description - The tile description
    # @param [Color] color - The ascii character representation color
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] w - The width
    # @param [Integer] h - The height
    # @param [Dictionary[String, void]] associated_tabs - List of associated tabs
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize name, description, color, row_index, column_index, drops,
                   associated_tabs, hit_points, associated_stockpile_type=nil
        @hit_points = hit_points
        @total_hit_points = hit_points

        super(name,
              description,
              'O',
              color,
              row_index,
              column_index,
              nil,
              drops,
              associated_tabs,
              associated_stockpile_type)
    end
end
