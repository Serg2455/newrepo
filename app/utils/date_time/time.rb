# A time object.
# @attr [Integer] hour - The hour
# @attr [Integer] minute - The minute

class Time
    # Defines constants
    HOURS_PER_DAY = 24
    MINUTES_PER_HOUR = 60

    attr_accessor :hour, :minute

    # Default constructor.
    # @param [Integer] hour - The hour
    # @param [Integer] minute - The minute
    def initialize hour, minute
        @hour = hour
        @minute = minute
    end

    # Adds a time object to the existing time object.
    # @param [Time] time - The time object to be added
    # @return [Integer] The day remainder
    def add time
        # Adds variables
        @hour = @hour + time.hour
        @minute = @minute + time.minute

        # Handles remainders
        if @minute >= MINUTES_PER_HOUR
            hours = MINUTES_PER_HOUR / @minute
            @minute = @minute % MINUTES_PER_HOUR
            @hour = @hour + hours
        end

        if @hour >= HOURS_PER_DAY
            days = HOURS_PER_DAY / @hour
            @hour = @hour % HOURS_PER_DAY
            return days # Has day remainder
        end

        0 # No day remainder
    end

    # Gets string representation.
    # @return [String] The string representation
    def to_s
        hour_string = hour.to_i.to_s
        hour_string = '0' + hour_string if hour_string.length < 2

        minute_string = minute.to_i.to_s
        minute_string = '0' + minute_string if minute_string.length < 2

        hour_string + ':' + minute_string
    end
end
