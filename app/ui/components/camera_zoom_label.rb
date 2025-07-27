require 'app/ui/hud'

class CameraZoomLabel
    attr_accessor :zoom_info, :zoom_info_timer

    def initialize
        @zoom_info = ''
        @zoom_info_timer = 0
    end

    def draw args
        args.outputs.primitives << {
            x: args.grid.w - Hud::RIGHT_MARGIN,
            y: Hud::BOTTOM_MARGIN,
            anchor_x: 1,
            anchor_y: 0,
            text: @zoom_info,
            size_px: 16,
            r: 255,
            g: 255,
            b: 255,
            font: 'fonts/departure-mono-reg.otf'
        }.label!

        if not @zoom_info.empty?
            @zoom_info_timer += 1
            if @zoom_info_timer >= 30
                @zoom_info = ''
                @zoom_info_timer = 0
            end
        end
    end
end
