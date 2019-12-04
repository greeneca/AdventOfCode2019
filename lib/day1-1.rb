def p11(input)
  input.map!{|m| m.to_i}

  total = 0
  input.each {|m|
    fuel = (m/3.0).floor-2
    total += fuel
  }

  puts "Total: #{total}"
end
