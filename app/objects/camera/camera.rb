# Controls the game viewport.
# @attr [Integer] x - The x-coordinate position (default: 0)
# @attr [Integer] y - The y-coordinate position (default: 0)
# @attr [Float] zoom - The zoom level (default: 1)
class Camera
    # Defines constants
    MOVE_SPEED = 5
    ZOOM_SPEED = 0.08

    attr_accessor :x, :y, :zoom

    # Default constructor.
    # @param [Integer] x - The x-coordinate position (default: 0)
    # @param [Integer] y - The y-coordinate position (default: 0)
    # @param [Float] zoom - The zoom level (default: 1)
    # @return [void]
    def initialize x=0, y=0, zoom=1
        @x = x
        @y = y
        @zoom = zoom
    end

    # Updates the camera.
    # @param [Args] args - DragonRuby arguments
    # @return [void]
    def tick args
        # If the alt key is not held down
        if not args.inputs.keyboard.alt
            # Moves camera with keyboard controls (i.e. WASD, arrow keys)
            args.state.camera.x += MOVE_SPEED if args.inputs.right
            args.state.camera.x -= MOVE_SPEED if args.inputs.left
            args.state.camera.y += MOVE_SPEED if args.inputs.up
            args.state.camera.y -= MOVE_SPEED if args.inputs.down
        end

        # Controls camera zoom with mouse wheel
        @zoom += args.inputs.mouse.wheel&.y.to_i * ZOOM_SPEED
        @zoom = @zoom.clamp(0.5, 2)
        # NOTE: This makes it easier to snap to the default zoom level
        @zoom = 1 if @zoom > 0.95 and @zoom < 1.05

        # If the mouse wheel is held down
        if args.inputs.mouse.wheel
            # Tells the GUI to display camera zoom info for a set amount of time
            args.state.hud.camera_zoom_label.zoom_info = @zoom.to_s
            i = args.state.hud.camera_zoom_label.zoom_info.index('.')
            if i
                # Formats zoom info by limiting number of decimal places
                length = args.state.hud.camera_zoom_label.zoom_info.length
                decimals = length - i - 1
                if decimals > 2
                    temp = args.state.hud.camera_zoom_label.zoom_info[0..i + 2]
                    args.state.hud.camera_zoom_label.zoom_info = temp
                end
            end
            args.state.hud.camera_zoom_label.zoom_info << 'x'
            # Resets the zoom info timer
            args.state.hud.camera_zoom_label.zoom_info_timer = 0
        end
    end
end
