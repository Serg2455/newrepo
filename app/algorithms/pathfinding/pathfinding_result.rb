# A pathfinding run result.
# @attr [Hash] velocity - The next-step velocity in x, y coordinates
# @attr [Float] actual_cost - The actual cost between start/end position
class PathfindingResult
    attr_accessor :velocity, :actual_cost

    # Default constructor.
    # @param [Hash] velocity - The next-step velocity (default: { x: 0, y: 0 })
    # @param [Float] actual_cost - The actual cost (default: 0)
    # @return [void]
    def initialize velocity={ x: 0, y: 0 }, actual_cost=0
        @velocity = velocity
        @actual_cost = actual_cost
    end
end
