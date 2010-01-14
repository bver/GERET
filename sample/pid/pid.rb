#!/usr/bin/ruby

# this script generates the data:
# ./pid.rb > data.csv

x = []
10.times {x << 0.00}
300.times {x << 2.00}
200.times {x << 1.00}


Kp = 1.0
Ki = 0.1
Kd = 0.5
Dt = 1.0
Response = 0.1

previous_error = 0.0
integral = 0.0 
actual_position = 0.0
output = 0.0

x.each do |setpoint|

  # "environment"
  actual_position += output * Response
 
  # PID controller
  error = setpoint - actual_position
  integral = integral + error*Dt
  derivative = (error - previous_error) / Dt
  previous_error = error
  output = (Kp*error) + (Ki*integral) + (Kd*derivative)

  puts "#{output},#{setpoint},#{actual_position}"
end

