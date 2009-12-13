#!/usr/bin/ruby

x = []
10.times {x << 0.00}
300.times {x << 2.00}
200.times {x << 1.00}


Kp = 1.0
Ki = 0.1
Kd = 4.0

previous_error = 0.0
integral = 0.0 
actual_position = 0.0
dt = 1.0
response = 0.1

x.each do |setpoint|

  error = setpoint - actual_position
  integral = integral + error*dt
  derivative = (error - previous_error) / dt
  output = (Kp*error) + (Ki*integral) + (Kd*derivative)
  previous_error = error

  actual_position += output * response

  puts "#{output},#{setpoint},#{actual_position}"
end

