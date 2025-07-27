require 'app/algorithms/shadowcasting/shadowcasting_quadrant'
require 'app/algorithms/shadowcasting/shadowcasting_row'

# Based off Albert Ford's symmetric shadowcasting algorithm.
# @see https://www.albertford.com/shadowcasting/
class Shadowcasting
    # Updates an entity's visible tiles array with every tile in its FOV.
    # @param [Args] args - DragonRuby arguments
    # @param [Entity] entity - The entity
    # @return [void]
    def self.compute_fov args, entity
        # The entity can always see the tile it is on
        entity.visible_tiles <<
            args.state.map.grid[entity.row_index][entity.column_index]

        # Computes FOV in all cardinal directions from the starting position
        for cardinal_direction in ShadowcastingQuadrant::CARDINAL_DIRECTIONS
            quadrant = ShadowcastingQuadrant.new(
                entity.row_index,
                entity.column_index,
                cardinal_direction)
            scan(args, entity, quadrant)
        end
    end

    # Updates an entity's visible tiles array with every tile in its FOV by
    # iterating through the rows of a given quadrant.
    # @private
    # @param [Args] args - DragonRuby arguments
    # @param [Entity] entity - The entity
    # @param [ShadowcastingQuadrant] quadrant - The quadrant
    # @return [void]
    def self.scan args, entity, quadrant
        # Initializes rows to scan through, starting with the first row
        rows = [ ShadowcastingRow.new(1, -1, 1) ]

        # While there are still rows to scan
        while not rows.empty?
            # Scans a row
            row = rows.pop
            previous_tile = nil
            previous_tile_transformed = nil

            # For each tile in the row
            row.tiles.each do |tile|
                # Transforms shadowcasting tile to actual tile
                tile_transformed = quadrant.transform(args, tile)
                next if tile_transformed.nil?

                if tile_transformed.wall? or symmetric(row, tile)
                    # The entity can see the tile
                    entity.visible_tiles << tile_transformed
                end

                if previous_tile_transformed
                    if previous_tile_transformed.wall? and
                       tile_transformed.floor?
                        row.start_slope = slope(tile)
                    end

                    if previous_tile_transformed.floor? and
                       tile_transformed.wall?
                        # Appends next row
                        next_row = row.next
                        next_row.end_slope = slope(tile)
                        rows << next_row
                    end
                end

                previous_tile = tile
                previous_tile_transformed = tile_transformed
            end

            # Appends next row
            rows << row.next if previous_tile_transformed and
                                previous_tile_transformed.floor?
        end
    end

    # Determines tile symmetry.
    # @private
    # @param [ShadowcastingRow] row - The row
    # @param [ShadowcastingTile] tile - The tile
    # @return [Boolean] true if symmetric; false otherwise
    def self.symmetric row, tile
        return (tile.column_index_shift >= row.depth * row.start_slope) and    \
               (tile.column_index_shift <= row.depth * row.end_slope)
    end

    # Calculates slope.
    # @private
    # @param [ShadowcastingTile] tile - The tile
    # @return [Float] The slope
    def self.slope tile
        return (2 * tile.column_index_shift - 1) / (2 * tile.row_depth)
    end

    # Rounds ties up.
    # @param [Integer] n - The value to round
    # @return [Integer] The rounded value
    def self.round_ties_up n
        return (n + 0.5).floor
    end

    # Rounds ties down.
    # @param [Integer] n - The value to round
    # @return [Integer] The rounded value
    def self.round_ties_down n
        return (n - 0.5).ceil
    end
end
