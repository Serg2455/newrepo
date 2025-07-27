require 'app/objects/environment/tiles/grass_tile'
require 'app/objects/environment/tiles/tile'
require 'app/utils/date_time/time'
require 'app/utils/color'
require 'app/utils/time_control'
require 'app/utils/utils'

# A dirt tile object. Turns into a grass tile over time.
# @attr [Float] growth_timer - The grass growth timer
# @attr [Float] growth_timer_target - The grass growth timer target
class DirtTile < Tile
    attr_accessor :growth_timer, :growth_timer_target

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        # Initializes grass growth timer settings
        @growth_timer = 0
        @growth_timer_target =
            FPS * Time::MINUTES_PER_HOUR * Time::HOURS_PER_DAY
        
        super('dirt',
              'Dry, compact earth with patches of scattered pebbles.',
              '_',
              Color::BROWN,
              row_index,
              column_index,
              1,
              {},
              { 'Zone' => nil },
              associated_stockpile_type)
    end

    # Updates dirt tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If the game is running (not paused)
        if args.state.time_control > 0
            # Increments timer
            @growth_timer += 1
            # If timer meets target
            if @growth_timer >= TimeControl.adjust(args, @growth_timer_target)
                # Changes tile to grass tile
                change_to(args, GrassTile.new(
                    @row_index,
                    @column_index,
                    @associated_stockpile_type))
                return
            end
        end

        super
    end
end
