require 'app/modules/other_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/dirt_tile'
require 'app/objects/environment/tiles/tile'
require 'app/objects/items/item'
require 'app/objects/tasks/craft_task'
require 'app/utils/color'

# A crafting bench tile object.
# @attr [Dictionary[Item, Integer]] required_resources - The required resources to craft
class CraftTile < Tile
    include HasHitPoints

    attr_accessor :required_resources, :crafted_item_count, :desired_craft_count

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        @hit_points = 0
        @total_hit_points = 3
        @required_resources = { WoodItem => 2 }
        @crafted_item_count = 0
        @desired_craft_count = 3

        super('crafting bench',
              'A crafting bench that stores swords.',
              'H',
              Color::ORANGE,
              row_index,
              column_index,
              1,
              {},
              { 'Craft' => nil, 'Zone' => nil },
              associated_stockpile_type,
              true)
    end

    # Updates crafting bench tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If not yet ready to craft
        if self.floor?
            # If ready to craft
            if @hit_points >= @total_hit_points
                sword = SwordItemEntity.new(@row_index, @column_index)
                args.state.entities << sword 
                @crafted_item_count += 1

                @required_resources.each do |item_class_type, count|
                    item_entity_class_type = item_class_type.new.item_entity_class_type
                    if @drops[item_entity_class_type]
                        @drops[item_entity_class_type] -= count
                        @drops.delete(item_entity_class_type) if @drops[item_entity_class_type]
                    end
                end

                @hit_points = 0

                if @crafted_item_count >= @desired_craft_count
                    @movement_difficulty = nil
                    @invincible = false
                    @associated_tabs = { 'Demolish' => nil }
                end
                
            elsif not self.tasked_with_class?(CraftTask)
                drop_items(args)
                change_to(args, DirtTile.new(
                    @row_index,
                    @column_index,
                    @associated_stockpile_type))
            end
        end

        super
    end

    # Determines whether the tile has the resources required to craft.
    # @return [Boolean] True if yes; false otherwise
    def has_required_resources?
        return self.missing_resources.nil?
    end

    # Gets missing resources preventing the tile from being able to craft.
    # @return [Dictionary[Class, Integer]] The missing resources
    def missing_resources
        result = nil
        @required_resources.each do |item_class_type, count|
            item_entity_class_type = item_class_type.new.item_entity_class_type
            num_needed = ((not @drops.key?(item_entity_class_type)) ? count :
                [ count - @drops[item_entity_class_type], 0 ].max)
            next if num_needed == 0
            # Found missing resource
            result = {} if result.nil?
            result[item_class_type] = num_needed
        end
        return result
    end
end
