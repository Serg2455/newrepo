# Based off Albert Ford's symmetric shadowcasting algorithm.
# @attr [Integer] row_depth - The row depth
# @attr [Integer] column_index_shift - The column index shift
# @see https://www.albertford.com/shadowcasting/
class ShadowcastingTile
    attr_accessor :row_depth, :column_index_shift

    # Default constructor.
    # @param [Integer] row_depth - The row depth
    # @param [Integer] column_index_shift - The column index shift
    # @return [void]
    def initialize row_depth, column_index_shift
        @row_depth = row_depth
        @column_index_shift = column_index_shift
    end
end
