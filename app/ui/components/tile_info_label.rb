require 'app/objects/entities/item_entity'
require 'app/objects/entities/persons/person_entity'
require 'app/ui/hud'

class TileInfoLabel
    def initialize
    end
    
    def draw args
        args.outputs.primitives << args.state.hud.hovered_objects.map_with_index do |obj, i|
            {
                x: Hud::LEFT_MARGIN,
                y: Hud::BOTTOM_MARGIN + args.state.hud.hovered_objects.length * 16,
                anchor_y: i,
                text: obj.name +
                      (obj.is_a?(ItemEntity) ? (' x' + obj.count.to_s) : '') +
                      ((obj.is_a?(PersonEntity) and obj.destroyed_or_dead?) ? ' (dead)' : ''),
                size_px: 16,
                r: 255,
                g: 255,
                b: 255,
                font: 'fonts/departure-mono-reg.otf'
            }.label!
        end
    end
end
