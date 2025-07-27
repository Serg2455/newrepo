# Allows class instances to have hit points.
# @attr [Float] hit_points - The current number of hit points
# @attr [Float] total_hit_points - The total number of hit points
module HasHitPoints
    attr_accessor :hit_points, :total_hit_points

    # Determines whether the class instance is destroyed or dead.
    # @return [Boolean] Whether the class instance is destroyed or dead
    def destroyed_or_dead?
        @hit_points <= 0
    end
end

# Allows class instances to have an inventory.
# @attr [Array[Item]] inventory - The inventory items
# @attr [Float] max_carrying_capacity - The maximum carrying capacity
module HasInventory
    attr_accessor :inventory, :max_carrying_capacity

    # Calculates current carrying capacity, or current weight carried.
    # @return [Float] The current carrying capacity
    def carrying_capacity
        inventory.sum do |inventory_item|
            inventory_item.weight * inventory_item.count
        end
    end

    # Adds item(s) to the inventory.
    # @param [Class] item_class_type - The class type of the item to add
    # @param [Integer] count - The number of items to add (default: 1)
    # @return [void]
    def add_to_inventory item_class_type, count=1
        existing = @inventory.find { |item| item.is_a?(item_class_type) }
        existing ? existing.count += count :
                   @inventory << item_class_type.new(count)
    end

    # Removes item(s) from the inventory.
    # @param [Class] item_class_type - The class type of the item to remove
    # @param [Integer] count - The number of items to remove (default: 1)
    # @return [Boolean] True if success; false otherwise
    def remove_from_inventory item_class_type, count=1
        existing = @inventory.find { |item| item.is_a?(item_class_type) }
        # Failed to find the inventory item
        return false if existing.nil?
        # Failed to find the required number of inventory items
        return false if existing.count < count
        # Found the specified item and amount
        existing.count -= count
        @inventory.delete(existing) if existing.count == 0
        return true
    end
end
