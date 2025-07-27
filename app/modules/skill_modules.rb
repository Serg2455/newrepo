# Allows class instances to gain melee experience.
# @attr [Float] melee_experience_points - The amount of melee experience points
module HasMeleeSkill
    attr_accessor :melee_experience_points
    
    # Gets the melee skill level.
    # @return [Integer] The melee skill level
    def melee_level
        [ (@melee_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the melee skill multiplier.
    # @return [Float] The melee skill multiplier
    def melee_mult
        2 * Math.log(1.2 * self.melee_level)
    end
end

# Allows class instances to gain archery experience.
# @attr [Float] melee_experience_points - The amount of archery experience points
module HasArcherySkill
    attr_accessor :archery_experience_points
    
    # Gets the archery skill level.
    # @return [Integer] The archery skill level
    def archery_level
        [ (@archery_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the archery skill multiplier.
    # @return [Float] The archery skill multiplier
    def archery_mult
        2 * Math.log(1.2 * self.archery_level)
    end
end

# Allows class instances to gain woodcutting experience.
# @attr [Float] melee_experience_points - The amount of woodcutting experience points
module HasWoodcuttingSkill
    attr_accessor :woodcutting_experience_points
    
    # Gets the woodcutting skill level.
    # @return [Integer] The woodcutting skill level
    def woodcutting_level
        [ (@woodcutting_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the woodcutting skill multiplier.
    # @return [Float] The woodcutting skill multiplier
    def woodcutting_mult
        2 * Math.log(1.2 * self.woodcutting_level)
    end
end

# Allows class instances to gain mining experience.
# @attr [Float] melee_experience_points - The amount of mining experience points
module HasMiningSkill
    attr_accessor :mining_experience_points
    
    # Gets the mining skill level.
    # @return [Integer] The mining skill level
    def mining_level
        [ (@mining_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the mining skill multiplier.
    # @return [Float] The mining skill multiplier
    def mining_mult
        2 * Math.log(1.2 * self.mining_level)
    end
end

# Allows class instances to gain building experience.
# @attr [Float] melee_experience_points - The amount of building experience points
module HasBuildingSkill
    attr_accessor :building_experience_points
    
    # Gets the building skill level.
    # @return [Integer] The building skill level
    def building_level
        [ (@building_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the building skill multiplier.
    # @return [Float] The building skill multiplier
    def building_mult
        2 * Math.log(1.2 * self.building_level)
    end
end

# Allows class instances to gain crafting experience.
# @attr [Float] melee_experience_points - The amount of crafting experience points
module HasCraftingSkill
    attr_accessor :crafting_experience_points
    
    # Gets the crafting skill level.
    # @return [Integer] The crafting skill level
    def crafting_level
        [ (@crafting_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the crafting skill multiplier.
    # @return [Float] The crafting skill multiplier
    def crafting_mult
        2 * Math.log(1.2 * self.crafting_level)
    end
end

# Allows class instances to gain planting experience.
# @attr [Float] melee_experience_points - The amount of planting experience points
module HasPlantingSkill
    attr_accessor :planting_experience_points
    
    # Gets the planting skill level.
    # @return [Integer] The planting skill level
    def planting_level
        [ (@planting_experience_points / 100).floor + 1, 10 ].min
    end

    # Gets the planting skill multiplier.
    # @return [Float] The planting skill multiplier
    def planting_mult
        2 * Math.log(1.2 * self.planting_level)
    end
end

# Allows class instances to perform tasks.
# @attr [Boolean] can_chop - Whether the instance can perform the chopping task
# @attr [Boolean] can_mine - Whether the instance can perform the mining task
# @attr [Boolean] can_build - Whether the instance can perform the building task
# @attr [Boolean] can_hunt - Whether the instance can perform the hunting task
# @attr [Boolean] can_farm - Whether the instance can perform the farming task
# @attr [Boolean] can_haul - Whether the instance can perform the hauling task
# @attr [Boolean] can_craft - Whether the instance can perform the crafting task
module CanPerformTasks
    attr_accessor :can_chop,
                  :can_mine,
                  :can_build,
                  :can_hunt,
                  :can_farm,
                  :can_haul,
                  :can_craft    # Added for crafting
    
    # Determines whether the entity can perform a specified task
    # @param [String] task_name - The task name
    # @return [Boolean] true if can perform; false otherwise
    def can_perform task_name
        # Sanitizes task name
        task_name = task_name.strip.upcase

        # All entities can perform these tasks
        return true if task_name == 'WANDER' or
                       task_name == 'PICK UP'

        # Some entities can perform these tasks
        return @can_chop if task_name == 'CHOP'
        return @can_mine if task_name == 'MINE'

        return @can_build if task_name == 'BUILD' or
                             task_name == 'DEMOLISH'

        return @can_hunt if task_name == 'HUNT'

        return @can_farm if task_name == 'FARM' or
                            task_name == 'CUT' or
                            task_name == 'FORAGE'

        return @can_haul if task_name == 'HAUL'

        return @can_craft if task_name == 'CRAFT'   # Added for crafting
    end

    # Enables the entity to perform a specified task
    # @param [String] task_name - The task name
    # @return [void]
    def enable_perform task_name
        # Sanitizes task name
        task_name = task_name.strip.upcase

        # Enables task
        @can_chop = true if task_name == 'CHOP'
        @can_mine = true if task_name == 'MINE'
        @can_build = true if task_name == 'BUILD'
        @can_hunt = true if task_name == 'HUNT'
        @can_farm = true if task_name == 'FARM'
        @can_haul = true if task_name == 'HAUL'
        @can_craft = true if task_name == 'CRAFT'   # Added for crafting
    end

    # Disables the entity from performing a specified task
    # @param [String] task_name - The task name
    # @return [void]
    def disable_perform task_name
        # Sanitizes task name
        task_name = task_name.strip.upcase

        # Disables task
        @can_chop = false if task_name == 'CHOP'
        @can_mine = false if task_name == 'MINE'
        @can_build = false if task_name == 'BUILD'
        @can_hunt = false if task_name == 'HUNT'
        @can_farm = false if task_name == 'FARM'
        @can_haul = false if task_name == 'HAUL'
        @can_craft = false if task_name == 'CRAFT'  # Added for crafting
    end
end

# Allows class instances to form relationships.
# @attr [Hash<Entity, Float>] relationships - The relationship levels
module CanSocialize
    attr_accessor :relationships
end
