# A global task manager object.
# @attr [Array[Task]] tasks - The list of unassigned tasks
class TaskManager
    attr_accessor :tasks

    # Default constructor.
    # @return [void]
    def initialize
        @tasks = []
    end
end
