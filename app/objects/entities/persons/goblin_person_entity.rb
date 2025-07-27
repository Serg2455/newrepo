require 'app/modules/skill_modules'
require 'app/objects/entities/persons/person_entity'
require 'app/utils/color'

# A goblin object.
class GoblinPersonEntity < PersonEntity
    include HasMeleeSkill
    include HasArcherySkill

    # Default constructor.
    # @param [String] name - The entity name
    # @param [String] description - The entity description
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @return [void]
    def initialize name, description, row_index, column_index
        @hit_points = 80
        @total_hit_points = 80

        @inventory = []
        @max_carrying_capacity = 45

        @melee_experience_points = 0
        @archery_experience_points = 0

        # Determines sex from description
        sex = (description.include?('female') ? 'female' : 'male')

        super(name,
              description,
              'goblin',
              sex,
              'G',
              Color::LIME_GREEN,
              row_index,
              column_index)
    end
end
