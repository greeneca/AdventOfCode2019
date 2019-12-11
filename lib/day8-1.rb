module P81
  class P81

    WIDTH = 25
    HEIGHT = 6

    def run(input)
      input = input.first.strip.split("").map{|i| i.to_i}
      layers = []
      while input.count > 0
        layers.push(input.slice!(0..(WIDTH*HEIGHT-1)))
      end

      puts "Checksum: #{calculateChecksum(layers)}"
    end

    private

    def calculateChecksum(layers)
      layers.sort! {|a, b| a.count(0) <=> b.count(0)}
      layers.first.count(1) * layers.first.count(2)
    end
  end
end
