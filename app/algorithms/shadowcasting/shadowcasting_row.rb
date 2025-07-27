require 'app/algorithms/shadowcasting/shadowcasting_tile'
require 'app/algorithms/shadowcasting/shadowcasting'

# Based off Albert Ford's symmetric shadowcasting algorithm.
# @attr [Integer] depth - The row depth
# @attr [Integer] start_slope - The start slope
# @attr [Integer] end_slope - The end slope
# @see https://www.albertford.com/shadowcasting/
class ShadowcastingRow
    attr_accessor :depth, :start_slope, :end_slope

    # Default constructor.
    # @param [Integer] depth - The row depth
    # @param [Integer] start_slope - The start slope
    # @param [Integer] end_slope - The end slope
    # @return [void]
    def initialize depth, start_slope, end_slope
        @depth = depth
        @start_slope = start_slope
        @end_slope = end_slope
    end

    # Gets row tiles.
    # @return [Array[ShadowcastingTile]] The row tiles
    def tiles
        min_shift = Shadowcasting.round_ties_up(@depth * @start_slope)
        max_shift = Shadowcasting.round_ties_down(@depth * @end_slope)

        result = []
        for column_index_shift in min_shift..max_shift
            result << ShadowcastingTile.new(@depth, column_index_shift)
        end
        return result
    end

    # Gets next row.
    # @return [ShadowcastingRow] The next row
    def next
        return ShadowcastingRow.new(@depth + 1, @start_slope, @end_slope)
    end
end
