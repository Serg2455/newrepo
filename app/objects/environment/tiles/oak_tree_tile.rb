require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/tree_tile'
require 'app/utils/color'

# An oak tree tile object.
class OakTreeTile < TreeTile
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        super('oak tree',
              'A broad, hardwood tree with a thick trunk and wide canopy of '  \
              'leaves.',
              Color::BROWN,
              row_index,
              column_index,
              {
                WoodItemEntity => 80
              },
              { 'Chop' => nil, 'Zone' => nil },
              120,
              associated_stockpile_type)
    end
end
