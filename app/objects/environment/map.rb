require 'app/modules/tile_modules'
require 'app/utils/utils'

# A map object. Holds game level and tile information.
# @attr [Integer] local_x - The local x-coordinate location
# @attr [Integer] local_y - The local y-coordinate location
# @attr [Array[Array[Tile]]] grid - The actual map, or tile grid
# @attr [Integer] num_foliage - The number of tiles that constitute foliage
class Map
    attr_accessor :local_x, :local_y, :grid, :num_foliage

    # Default constructor.
    # @param [Integer] x - The x-coordinate location (default: 0)
    # @param [Integer] y - The y-coordinate location (default: 0)
    # @param [Integer] num_rows - The number of rows (default: 0)
    # @param [Integer] num_columns - The number of columns (default: 0)
    # @return [void]
    def initialize x=0, y=0, num_rows=0, num_columns=0
        @local_x = x
        @local_y = y

        @grid = []
        @num_foliage = 0

        # Generate grid
        for i in 0..num_rows - 1
            # Create row
            grid[i] = []

            for j in 0..num_columns - 1
                rng = rand

                # Create randomized tile
                grid[i][j] = OakTreeTile.new(i, j)
                grid[i][j] = AppleTreeTile.new(i, j) if rng > 0.08
                grid[i][j] = BerryBushTile.new(i, j) if rng > 0.1
                grid[i][j] = TallGrassTile.new(i, j) if rng > 0.12
                grid[i][j] = GrassTile.new(i, j) if rng > 0.45

                # Update foliage metadata
                @num_foliage += 1 if grid[i][j].is_a?(IsFoliage)
            end
        end
    end

    # Updates map.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # Updates tiles
        grid.each { |row| row.each { |tile| tile.tick args } }
    end

    # Draws map.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def draw args
        # Draws tiles
        grid.each { |row| row.each { |tile| tile.draw args } }
    end

    # Gets number of rows.
    # @return [Integer] The number of rows
    def num_rows
        grid.length
    end

    # Gets number of columns.
    # @return [Integer] The number of columns
    def num_columns
        grid.empty? ? 0 : grid.first.length
    end

    # Gets number of tiles.
    # @return [Integer] The number of tiles
    def num_tiles
        self.num_rows * self.num_columns
    end
    
    # Gets global map x position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global map x position
    def global_x args
        return @local_x if args.state.camera.nil? or args.state.viewport.nil?
        args.state.viewport.x + @local_x * args.state.camera.zoom
    end

    # Gets global map y position.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global map y position
    def global_y args
        adjusted_y = @local_y + self.local_h
        return adjusted_y if args.state.camera.nil? or args.state.viewport.nil?
        args.state.viewport.y + adjusted_y * args.state.camera.zoom
    end

    # Gets global map width.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global map width
    def global_w args
        return self.local_w if args.state.camera.nil?
        self.local_w * args.state.camera.zoom
    end

    # Gets global map height.
    # @param [Args] args - DragonRuby arguments
    # @return [Float] The global map height
    def global_h args
        return self.local_w if args.state.camera.nil?
        self.local_h * args.state.camera.zoom
    end

    # Gets local map width.
    # @return [Float] The local map width
    def local_w
        self.num_columns * TILE_SIZE
    end

    # Gets local map height.
    # @return [Float] The local map height
    def local_h
        self.num_rows * TILE_SIZE
    end

    # Gets ratio of foliage tiles to non-foliage tiles.
    # @return [Float] The foliage ratio (num_foliage / num_tiles)
    def foliage_ratio
        num_foliage / num_tiles
    end
end
