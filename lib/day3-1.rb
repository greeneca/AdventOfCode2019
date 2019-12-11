module P31
  class P31
    def run(input)
      wires = input
      wires.map!{|wire| wire.split(",")}

      board = Hash.new()

      wires.each_index do |idx|
        wire = wires[idx]
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
            location = board[position]
            location ||= Array.new()
            board[position] = location.push(idx)
          end
        end
      end


      board.select!{|k,v| v.uniq.count > 1}
      intersections = []
      board.each do |k,v|
        intersections.push(k.to_a[0].map{|i| i.abs}.inject(0){|sum,x| sum + x})
      end
      intersections.sort!

      puts "Distance: #{intersections.first}"
    end
  end
end
