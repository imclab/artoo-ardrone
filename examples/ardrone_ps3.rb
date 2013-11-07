require 'artoo'

connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
device :drone, :driver => :ardrone, :connection => :ardrone

connection :joystick, :adaptor => :joystick
device :controller, :driver => :ps3, :connection => :joystick, :interval => 0.01

OFFSETS = {
  :dx => 32767.0
}
@toggle_camera = 0

work do
  on controller, :button_square => proc { drone.take_off }
  on controller, :button_triangle => proc { drone.hover }
  on controller, :button_x => proc { drone.land }
  on controller, :button_circle => proc { 
    unless @toggle_camera
      drone.bottom_camera
      @toggle_camera = 1
    else
      drone.front_camera
      @toggle_camera = 0
    end
  }
  on controller, :button_home => proc { drone.emergency }
  on controller, :button_start => proc { drone.start }
  on controller, :button_select => proc { drone.stop }

  on controller, :joystick_0 => proc { |*value|
    pair = value[1]
    if pair[:y] < 0
      drone.forward(validate_pitch(pair[:y], OFFSETS[:dx]))
    elsif pair[:y] > 0
      drone.backward(validate_pitch(pair[:y], OFFSETS[:dx]))
    else
      drone.forward(0.0)
    end

    if pair[:x] > 0
      drone.right(validate_pitch(pair[:x], OFFSETS[:dx]))
    elsif pair[:x] < 0
      drone.left(validate_pitch(pair[:x], OFFSETS[:dx]))
    else
      drone.right(0.0)
    end
  }

  on controller, :joystick_1 => proc { |*value|
    pair = value[1]
    if pair[:y] < 0
      drone.up(validate_pitch(pair[:y], OFFSETS[:dx]))
    elsif pair[:y] > 0
      drone.down(validate_pitch(pair[:y], OFFSETS[:dx]))
    else
      drone.up(0.0)
    end

    if pair[:x] > 0
      drone.turn_right(validate_pitch(pair[:x], OFFSETS[:dx]))
    elsif pair[:x] < 0
      drone.turn_left(validate_pitch(pair[:x], OFFSETS[:dx]))
    else
      drone.turn_right(0.0)
    end
  }
end

def validate_pitch(data, offset)
  value = data.abs / offset
  value >= 0.1 ? (value <= 1.0 ? value.round(2) : 1.0) : 0.0
end
