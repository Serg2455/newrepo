require 'app/objects/entities/entity'
require 'app/objects/items/item'
require 'app/utils/color'

# An item stack entity abstract.
# @attr [Class] item_class_type - The class type of the item (non-entity)
# @attr [Integer] count - The number of items in the stack
class ItemEntity < Entity
    attr_accessor :item_class_type, :count

    # Default constructor.
    # @param [String] name - The entity name
    # @param [String] description - The entity description
    # @param [Character] ascii - The ascii character representation
    # @param [Color] color - The ascii character representation text color 
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Class] item_class_type - The class type of the item (non-entity)
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize name, description, ascii, color, row_index, column_index,
                   item_class_type, count=1
        @item_class_type = item_class_type
        @count = count
        
        super name, description, ascii, color, row_index, column_index
    end
end

# A food item stack entity abstract.
class FoodItemEntity < ItemEntity
end

# A pickaxe item stack entity object.
class PickaxeItemEntity < ItemEntity
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize row_index, column_index, count=1
        super('pickaxe',
              'A sturdy iron pickaxe.',
              'p',
              Color::WHITE,
              row_index,
              column_index,
              PickaxeItem,
              count)
    end
end

# A wood item stack entity object.
class WoodItemEntity < ItemEntity
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize row_index, column_index, count=1
        super('wood',
              'A sturdy block of wood.',
              '=',
              Color::BROWN,
              row_index,
              column_index,
              WoodItem,
              count)
    end
end

# An apple item stack entity object.
class AppleItemEntity < FoodItemEntity
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize row_index, column_index, count=1
        super('apple',
              'A juicy, red apple.',
              'a',
              Color::RED,
              row_index,
              column_index,
              AppleFoodItem,
              count)
    end
end

# A berry item stack entity object.
class BerryItemEntity < FoodItemEntity
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize row_index, column_index, count=1
        super('berry',
              'A small, red berry.',
              'b',
              Color::RED,
              row_index,
              column_index,
              BerryFoodItem,
              count)
    end
end

# A sword item stack entity object. added for crafting wooden swords
class SwordItemEntity < ItemEntity
    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] count - The number of items in the stack
    # @return [void]
    def initialize row_index, column_index, count=1
        super('wooden sword',
              'A blunt wooden sword.',
              'T',
              Color::ORANGE,
              row_index,
              column_index,
              SwordItem,
              count)
    end
end