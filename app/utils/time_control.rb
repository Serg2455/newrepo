# Time control util.
class TimeControl
    # Adjusts a timer target by the time control multiplier. Timer targets are
    # lowered at faster time controls, and raised at slower time controls.
    # @param [Args] args - DragonRuby args
    # @param [Float] timer_target - The timer target to adjust
    # @return [Float] The adjusted timer target
    def self.adjust args, timer_target
        # NOTE: This function should never be called while the game is paused
        return timer_target if args.state.time_control == 0 # Fail-safe
        return timer_target / mult(args)
    end

    # Returns the active time control multiplier.
    # @args [Args] args - DragonRuby args
    # @return [Float] The multiplier if game running; nil if game paused
    def self.mult args
        return 1 if args.state.time_control == 1
        return 1.5 if args.state.time_control == 2
        return 2 if args.state.time_control == 3
        return 3 if args.state.time_control == 4
        return nil
    end
end
