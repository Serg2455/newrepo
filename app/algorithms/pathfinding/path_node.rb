# A pathfinding node.
# @attr [PathNode] parent - The parent node
# @attr [Integer] row_index - The row index
# @attr [Integer] column_index - The column index
# @attr [Integer] g - The actual cost
# @attr [Integer] h - The heuristic estimate
# @attr [Integer] f - The total estimated cost
class PathNode
    attr_accessor :parent, :row_index, :column_index, :g, :h, :f

    # Default constructor.
    # @param [PathNode] parent - The parent node
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] g - The heuristic estimate
    # @param [Integer] h - The estimated cost
    # @return [void]
    def initialize (parent, row_index, column_index, g, h)
        @parent = parent
        @row_index = row_index
        @column_index = column_index
        @g = g
        @h = h
        @f = g + h
    end
end
