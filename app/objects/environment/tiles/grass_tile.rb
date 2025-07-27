require 'app/modules/other_modules'
require 'app/modules/tile_modules'
require 'app/objects/environment/tiles/apple_tree_tile'
require 'app/objects/environment/tiles/berry_bush_tile'
require 'app/objects/environment/tiles/oak_tree_tile'
require 'app/objects/environment/tiles/tall_grass_tile'
require 'app/objects/environment/tiles/tile'
require 'app/utils/date_time/time'
require 'app/utils/color'
require 'app/utils/debug'
require 'app/utils/time_control'
require 'app/utils/utils'

# A grass tile object. Turns into a randomized foliage tile over time.
# @attr [Float] spawn_timer - The foliage spawn timer
# @attr [Float] spawn_timer_target - The foliage spawn timer target
class GrassTile < Tile
    attr_accessor :spawn_timer, :spawn_timer_target

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        # Initializes foliage spawn timer settings
        @spawn_timer = 0
        # NOTE: Timer target only set when foliage ratio is below threshold
        @spawn_timer_target = nil

        super('grass',
              'Short, green blades covering the ground in a soft, even layer.',
              ',',
              Color::GREEN,
              row_index,
              column_index,
              1,
              {},
              { 'Zone' => nil },
              associated_stockpile_type)
    end

    # Updates grass tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If the game is running (not paused)
        if args.state.time_control > 0
            # If foliage ratio below threshold
            if args.state.map.foliage_ratio <= 0.75
                # Increments timer
                @spawn_timer += 1
                # If timer target not set
                if @spawn_timer_target.nil?
                    # Sets timer target
                    rng = rand(Time::HOURS_PER_DAY * 4 + 1)
                    hours = Time::HOURS_PER_DAY * 3 + rng
                    @spawn_timer_target = FPS * Time::MINUTES_PER_HOUR * hours
                end

                # If timer meets target
                if @spawn_timer >= TimeControl.adjust(args, @spawn_timer_target)
                    # Changes tile to randomized foliage tile
                    change_to(args, [
                        TallGrassTile,
                        BerryBushTile,
                        OakTreeTile,
                        AppleTreeTile
                    ].sample.new(
                        @row_index,
                        @column_index,
                        @associated_stockpile_type))
                    
                    return
                end
            else
                # Resets timer settings
                @spawn_timer = 0
                @spawn_timer_target = nil
            end
        end

        super
    end
end
