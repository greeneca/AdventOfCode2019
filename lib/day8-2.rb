module P82
  class P82

    WIDTH = 25
    HEIGHT = 6

    def run(input)
      input = input.first.strip.split("").map{|i| i.to_i}
      layers = []
      while input.count > 0
        layers.push(input.slice!(0..(WIDTH*HEIGHT-1)))
      end

      master_layer = []
      layers.first.each_index do |idx|
        layers.each do |layer|
          next if layer[idx] == 2
          master_layer[idx] = layer[idx]
          break
        end
      end
      rows = []
      while master_layer.count > 0
        rows.push(master_layer.slice!(0..WIDTH-1))
      end
      rows.each do |row|
        puts row.map{|a| a == 0 ? " " : a}.join("")
      end
    end

    private

    def calculateChecksum(layers)
      layers.sort! {|a, b| a.count(0) <=> b.count(0)}
      layers.first.count(1) * layers.first.count(2)
    end
  end
end
