require 'app/ui/hud'

class TimeInfoLabel
    def initialize
    end

    def draw args
        args.outputs.primitives << {
            x: Hud::LEFT_MARGIN,
            y: Hud::BOTTOM_MARGIN,
            anchor_y: 0,
            text: args.state.date_time.to_s,
            size_px: 16,
            r: 255,
            g: 255,
            b: 255,
            font: 'fonts/departure-mono-reg.otf'
        }.label!
    end
end
