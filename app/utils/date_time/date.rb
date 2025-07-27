# A date object.
# @attr [Integer] year - The year
# @attr [Integer] month - The month
# @attr [Integer] week - The week
# @attr [Integer] day - The day
class Date
    # Defines constants
    MONTHS_PER_YEAR = 12
    WEEKS_PER_MONTH = 4
    DAYS_PER_WEEK = 7

    MONTHS = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
    ]

    attr_accessor :year, :month, :week, :day

    # Default constructor.
    # @param [Integer] year - The year (default: 0)
    # @param [Integer] month - The month (default: 1)
    # @param [Integer] week - The week (default: 0)
    # @param [Integer] day - The day (default: 0)
    # @return [void]
    def initialize year=0, month=1, week=0, day=0
        # NOTE: Month is decremented by one because it is intuitive to think of
        # month=1 as January when, internally, January is defined at index zero
        @year = year
        @month = month - 1
        @week = week
        @day = day
    end

    # Adds a date object to the existing date object.
    # @param [Date] date - The date object to be added
    # @return [void]
    def add date
        # Adds variables
        @year = @year + date.year
        @month = @month + date.month
        @day = @day + date.day

        # Handles remainders
        if @day >= DAYS_PER_WEEK
            weeks = DAYS_PER_WEEK / @day
            @day = @day % DAYS_PER_WEEK
            @week = @week + weeks
        end

        if @week >= WEEKS_PER_MONTH
            months = WEEKS_PER_MONTH / @week
            @week = @week % WEEKS_PER_MONTH
            @month = @month + months
        end

        if @month >= MONTHS_PER_YEAR
            years = MONTHS_PER_YEAR / @month
            @month = @month % MONTHS_PER_YEAR
            @year = @year + years
        end
    end

    # Gets day suffix (e.g. 'st' for 1, 'nd' for 2)
    # @param [Integer] day - The day
    # @return [String] The day suffix
    def day_suffix day
        day = day + 1
        last_digit = day % 10

        if day < 10 or day > 20
            return 'st' if last_digit == 1
            return 'nd' if last_digit == 2
            return 'rd' if last_digit == 3
        end

        'th'
    end

    # Gets string representation.
    # @return [String] The string representation
    def to_s
        month_string = MONTHS[@month.to_i].to_s

        day_string = (@week * DAYS_PER_WEEK + @day + 1).to_i.to_s
        day_string = day_string + day_suffix(day_string.to_i - 1)

        year_string = @year.to_i.to_s

        month_string + ' ' + day_string + ', ' + year_string
    end
end
