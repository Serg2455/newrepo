# An RGB-defined color.
# @attr [Integer] r - Red value
# @attr [Integer] g - Green value
# @attr [Integer] b - Blue value
class Color
    attr_accessor :r, :g, :b

    # Default constructor
    # @param [Integer] r - Red value (default: 0)
    # @param [Integer] g - Green value (default: 0)
    # @param [Integer] b - Blue value (default: 0)
    def initialize r=0, g=0, b=0
        @r = r
        @g = g
        @b = b
    end

    # Gets hash representation.
    # @return [Hash] The hash representation
    def as_hash
        { r: @r, g: @g, b: @b }
    end
end

# Defines constants
Color::BLACK = Color.new
Color::WHITE = Color.new(255, 255, 255)
Color::RED = Color.new(255, 0, 0)
Color::GREEN = Color.new(0, 255, 0)
Color::BLUE = Color.new(0, 0, 255)
Color::CYAN = Color.new(0, 255, 255)
Color::BROWN = Color.new(139, 69, 19)
Color::LIME_GREEN = Color.new(170, 255, 0)
Color::ORANGE = Color.new(255, 165, 0)
