#!/usr/bin/ruby

# this script generates the data:
# ./pid.rb > data.csv

x = []
10.times {x << 0.00}
300.times {x << 2.00}
200.times {x << 1.00}


Kp = 1.0
Ki = 0.1
Kd = 4.0
Dt = 1.0
Response = 0.1

previous_error = 0.0
integral = 0.0 
actual_position = 0.0

x.each do |setpoint|

  # PID controller
  error = setpoint - actual_position
  integral = integral + error*Dt
  derivative = (error - previous_error) / Dt
  output = (Kp*error) + (Ki*integral) + (Kd*derivative)
  previous_error = error

  # "environment"
  actual_position += output * Response

  puts "#{output},#{setpoint},#{actual_position}"
end

