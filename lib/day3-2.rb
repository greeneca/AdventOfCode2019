module P32
  class P32
    def run(input)
      wires = input
      wires.map!{|wire| wire.split(",")}

      board = Hash.new()

      wires.each_index do |idx|
        wire = wires[idx]
        wire_length = 0
        position = Matrix[[0,0]]
        wire.each do |run|
          movement = Matrix[[0,0]]
          case run[0]
          when "U"
            movement = Matrix[[0,1]]
          when "D"
            movement = Matrix[[0,-1]]
          when "L"
            movement = Matrix[[-1,0]]
          when "R"
            movement = Matrix[[1,0]]
          end
          run[1..-1].to_i.times do |i|
            position += movement
            wire_length += 1
            location = board[position]
            location ||= Array.new(wires.count)
            location[idx] = wire_length
            board[position] = location
          end
        end
      end


      board.select!{|k,v| v.keep_if{|v| not v.nil?}.count > 1}
      intersections = []
      board.each do |k,v|
        intersections.push(v.inject(0){|sum,x| sum + x})
      end
      intersections.sort!

      puts "Distance: #{intersections.first}"
    end
  end
end
