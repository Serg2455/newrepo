# A datetime object.
# @attr [Date] date - The date
# @attr [Time] time - The time
class DateTime
    attr_accessor :date, :time

    # Default constructor.
    # @param [Date] date - The date
    # @param [Time] time - The time
    def initialize date, time
        @date = date
        @time = time
    end

    # Adds a datetime object to the existing datetime object.
    # @param [DateTime] date_time - The datetime object to be added
    # @return [void]
    def add date_time
        days_remainder = @time.add(date_time.time)
        @date.add(Date.new(0, 1, 0, days_remainder))
        @date.add(date_time.date)
    end

    # Gets string representation.
    # @return [String] The string representation
    def to_s
        @date.to_s + ' ' + @time.to_s
    end
end
