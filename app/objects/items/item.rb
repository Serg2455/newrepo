# A stack of items.
# @attr [String] name - The item name
# @attr [Float] weight - The item weight (for a singular item)
# @attr [Class] item_entity_class_type - The class type of the item (entity)
# @attr [Integer] count - The number of items in the stack
class Item
    attr_accessor :name, :weight, :item_entity_class_type, :count

    # Default constructor.
    # @param [String] name - The item name
    # @param [Float] weight - The item weight (for a singular item)
    # @param [Class] item_entity_class_type - The class type of the item (entity)
    # @param [Integer] count - The number of items in the stack (default: 1)
    # @return [void]
    def initialize name, weight, item_entity_class_type, count=1
        @name = name
        @weight = weight
        @item_entity_class_type = item_entity_class_type
        @count = count
    end
end

# A stack of food items.
# @attr [Float] nourishment - The amount of hunger gained upon eating
class FoodItem < Item
    attr_accessor :nourishment

    # Default constructor.
    # @param [String] name - The item name
    # @param [Float] weight - The item weight (for a singular item)
    # @param [Float] nourishment - The amount of hunger gained upon eating
    # @param [Class] item_entity_class_type - The class type of the item (entity)
    # @param [Integer] count - The number of items in the stack (default: 1)
    # @return [void]
    def initialize name, weight, nourishment, item_entity_class_type, count=1
        @nourishment = nourishment
        super(name, weight, item_entity_class_type, count)
    end
end

# A pickaxe item object.
class PickaxeItem < Item
    # Default constructor.
    # @return [void]
    def initialize count=1
        super('pickaxe', 5, PickaxeItemEntity, count)
    end
end

# A wood item object.
class WoodItem < Item
    # Default constructor.
    # @return [void]
    def initialize count=1
        super('wood', 3, WoodItemEntity, count)
    end
end

# An apple food item object.
class AppleFoodItem < FoodItem
    # Default constructor.
    # @return [void]
    def initialize count=1
        super('apple', 1, 25, AppleItemEntity, count)
    end
end

# A berry food item object.
class BerryFoodItem < FoodItem
    # Default constructor.
    # @return [void]
    def initialize count=1
        super('berry', 0, 5, BerryItemEntity, count)
    end
end

# A pickaxe item object.
class SwordItem < Item
    # Default constructor.
    # @return [void]
    def initialize count=1
        super('wooden sword', 5, SwordItemEntity, count)
    end
end