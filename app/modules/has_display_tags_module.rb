# Allows class instances to have tags for display purposes.
# E.g. impassable tiles have the 'Wall' display tag
module HasDisplayTags
    # Gets display tags based on class inheritance and includes.
    # @return [Array[DisplayTag]] The display tags
    def display_tags
        tags = []

        # Gets tile type tags (if any)
        if is_a?(Tile)
            tags << DisplayTag.new(DisplayTag::FLOOR, self) if self.floor?
            tags << DisplayTag.new(DisplayTag::WALL, self) if self.wall?
        end

        # Gets item tags (if any)
        tags << DisplayTag.new(DisplayTag::ITEM, self) if is_a?(ItemEntity)

        # Gets species tags (if any)
        tags << DisplayTag.new(DisplayTag::DWARF, self) if is_a?(DwarfPersonEntity)
        tags << DisplayTag.new(DisplayTag::GOBLIN, self) if is_a?(GoblinPersonEntity)

        # Gets sex tags (if any)
        if is_a?(PersonEntity)
            male = @sex.upcase == 'MALE'
            female = @sex.upcase == 'FEMALE'

            tags << DisplayTag.new(DisplayTag::MALE, self) if male
            tags << DisplayTag.new(DisplayTag::FEMALE, self) if female
        end

        return tags
    end

    # A tag structure for display purposes.
    # E.g. impassable tiles have the 'Wall' tag
    # @attr [Integer] type - The display tag type
    # @attr [Object] it - The tagged object ("tag, you're it")
    class DisplayTag
        # Defines tile display tag types
        FLOOR = 0
        WALL = 1
        
        # Defines item display tag types
        ITEM = 10

        # Defines species display tag types
        DWARF = 20
        GOBLIN = 21

        # Defines sex display tag types
        MALE = 30
        FEMALE = 31

        attr_accessor :type, :it

        # Default constructor.
        # @param [Integer] type - The display tag type
        # @param [Object] it - The tagged object ("tag, you're it")
        # @return [void]
        def initialize type, it
            @type = type
            @it = it
        end

        # Gets string representation.
        # @return [String] The string representation
        def to_s
            # Stringifies tile display tags
            return 'Floor' if @type == FLOOR
            return 'Wall' if @type == WALL

            # Strinifies item display tags
            return 'Item' if @type == ITEM

            # Stringifies species display tags
            return 'Dwarf' if @type == DWARF
            return 'Goblin' if @type == GOBLIN
            
            # Stringifies sex display tags
            return 'Male' if @type == MALE
            return 'Female' if @type == FEMALE

            return nil # NOTE: This should never happen
        end
    end
end
 