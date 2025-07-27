# Based off Albert Ford's symmetric shadowcasting algorithm.
# @attr [Integer] row_index - The row index
# @attr [Integer] column_index - The column index
# @attr [Integer] cardinal_direction - The cardinal direction
# @see https://www.albertford.com/shadowcasting/
class ShadowcastingQuadrant
    # Defines constants
    NORTH = 0
    SOUTH = 1
    EAST = 2
    WEST = 3

    CARDINAL_DIRECTIONS = [
        NORTH,
        SOUTH,
        EAST,
        WEST
    ]

    attr_accessor :row_index, :column_index, :cardinal_direction

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] cardinal_direction - The cardinal direction
    # @return [void]
    def initialize row_index, column_index, cardinal
        @row_index = row_index
        @column_index = column_index
        @cardinal = cardinal
    end
    
    # Gets an actual tile from a shadowcasting tile by applying a
    # transformation.
    # @param [Args] args - DragonRuby arguments
    # @param [ShadowcastingTile] tile -
    # @return [Tile] The actual tile; nil if position falls outside map bounds
    def transform args, tile
        row_index = nil
        column_index = nil

        # Transforms position
        if @cardinal == NORTH
            row_index = @row_index - tile.row_depth
            column_index = @column_index + tile.column_index_shift
        elsif @cardinal == SOUTH
            row_index = @row_index + tile.row_depth
            column_index = @column_index + tile.column_index_shift
        elsif @cardinal == EAST
            row_index = @row_index + tile.column_index_shift
            column_index = @column_index + tile.row_depth
        elsif @cardinal == WEST
            row_index = @row_index + tile.column_index_shift
            column_index = @column_index - tile.row_depth
        end

        # NOTE: This should never happen
        return nil if row_index.nil? or column_index.nil?

        # Returns nil if transformed position falls outside map bounds
        return nil if row_index < 0 or
                      row_index >= args.state.map.num_rows or
                      column_index < 0 or
                      column_index >= args.state.map.num_columns

        # Returns actual tile
        return args.state.map.grid[row_index][column_index]
    end
end
