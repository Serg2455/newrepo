require 'app/modules/other_modules'
require 'app/objects/entities/item_entity'
require 'app/objects/environment/tiles/dirt_tile'
require 'app/objects/environment/tiles/tile'
require 'app/objects/items/item'
require 'app/objects/tasks/build_task'
require 'app/utils/color'

# A fence tile object.
# @attr [Dictionary[Item, Integer]] required_resources - The required resources to build
class FenceTile < Tile
    include HasHitPoints

    attr_accessor :required_resources

    # Default constructor.
    # @param [Integer] row_index - The row index
    # @param [Integer] column_index - The column index
    # @param [Integer] associated_stockpile_type - The associated stockpile type (default: nil)
    # @return [void]
    def initialize row_index, column_index, associated_stockpile_type=nil
        @hit_points = 0
        @total_hit_points = 50
        @required_resources = { WoodItem => 10 }
        
        super('oak fence',
              'A rickety fence made of unprocessed oak wood.',
              '#',
              Color::BROWN,
              row_index,
              column_index,
              1,
              {},
              { 'Build' => nil, 'Zone' => nil },
              associated_stockpile_type,
              true)
    end

    # Updates fence tile.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If not yet fully built
        if self.floor?
            # If ready to fully build
            if @hit_points >= @total_hit_points
                # Changes into wall tile
                @movement_difficulty = nil
                @invincible = false
                @associated_tabs = { 'Demolish' => nil }
            elsif not self.tasked_with_class?(BuildTask)
                # Drops items
                drop_items(args)
                # Changes tile into dirt tile
                change_to(args, DirtTile.new(
                    @row_index,
                    @column_index,
                    @associated_stockpile_type))
            end
        end

        super
    end

    # Determines whether the tile has the resources required to build.
    # @return [Boolean] True if yes; false otherwise
    def has_required_resources?
        return self.missing_resources.nil?
    end

    # Gets missing resources preventing the tile from being built.
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
