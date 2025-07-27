require 'app/algorithms/pathfinding/pathfinding'
require 'app/modules/need_modules'
require 'app/modules/skill_modules'
require 'app/objects/entities/persons/person_entity'
require 'app/objects/items/item'
require 'app/utils/color'

# A dwarf object.
class DwarfPersonEntity < PersonEntity
    include HasMeleeSkill
    include HasArcherySkill
    include HasWoodcuttingSkill
    include HasMiningSkill
    include HasBuildingSkill
    include HasPlantingSkill
    include CanSocialize
    include NeedsFood
    include NeedsSleep
    include NeedsFun
    include HasCraftingSkill

    # Default constructor.
    # @param [String] name - The entity name
    # @param [String] description - The entity description
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @return [void]
    def initialize name, description, row_index, column_index
        @hit_points = 120
        @total_hit_points = 120

        @inventory = [ PickaxeItem.new ]
        @max_carrying_capacity = 180

        @melee_experience_points = 0
        @archery_experience_points = 0
        @woodcutting_experience_points = 0
        @mining_experience_points = 0
        @building_experience_points = 0
        @planting_experience_points = 0
        @crafting_experience_points = 0

        @relationships = {}

        @hunger = 100
        @max_hunger = 100
        @hunger_timer = 0
        @hunger_timer_target = 432

        @sleep = 100
        @max_sleep = 100
        @sleep_timer = 0
        @sleep_timer_target = 864

        @fun = 100
        @max_fun = 100
        @fun_timer = 0
        @fun_timer_target = 864

        @can_chop = true
        @can_mine = true
        @can_build = true
        @can_farm = true
        @can_hunt = true
        @can_haul = true
        @can_craft = true   # added for crafting

        # Determines sex from description
        sex = (description.include?('female') ? 'female' : 'male')

        super(name,
              description,
              'dwarf',
              sex,
              'D',
              Color::WHITE,
              row_index,
              column_index)
    end

    # Takes an action.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def act args
        act_hunger(args)

        # If there is no task assigned
        if @task.nil?
            # Finds the closest available task
            closest_unassigned_task = nil
            least_dist = nil

            args.state.task_manager.tasks.each do |unassigned_task|
                # Ignores unperformable tasks
                next if not can_perform(unassigned_task.name) and
                        not unassigned_task.override_can_perform
                next if not unassigned_task.performable(args, self)

                result = Pathfinding.a_star(
                    args,
                    @row_index,
                    @column_index,
                    unassigned_task.goal.row_index,
                    unassigned_task.goal.column_index,
                    unassigned_task.goal_radius)
                next if not result # Ignores unreachable tasks

                # Records new closest available task
                if closest_unassigned_task.nil? or
                   result.actual_cost < least_dist
                    closest_unassigned_task = unassigned_task
                    least_dist = result.actual_cost
                end
            end

            # If an available task exists
            if closest_unassigned_task
                # Assigns task
                @task = closest_unassigned_task
                @task.assignee = self
                args.state.task_manager.tasks.delete(@task)
            end
        end

        super
    end
end
