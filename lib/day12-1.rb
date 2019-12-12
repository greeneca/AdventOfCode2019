module P121
  class P121

    STEPS = 1000

    def run(input)
      input.map!{|line| line.gsub(/<|>/, "").split(",").map{|n| n.gsub(/.*=/, "").to_i}}
      moons = input.map{|pos| Moon.new(pos)}
      STEPS.times do
        moons.combination(2).each do |pair|
          pair.first.adjust_velocity(pair.last)
          pair.last.adjust_velocity(pair.first)
        end
        moons.each do |moon|
          moon.apply_velocity
        end
      end
      puts "Total Energy: #{moons.inject(0){|sum,moon| sum + moon.energy}}"
    end
  end

  class Moon
    attr_reader :position
    def initialize(position)
      @position = Matrix[position]
      @velocity = Matrix[[0,0,0]]
    end

    def adjust_velocity(moon)
      adjustment = []
      @position.each_with_index do |value, x, y|
        if value > moon.position[x,y]
          adjustment.push(-1)
        elsif value < moon.position[x,y]
          adjustment.push(1)
        else
          adjustment.push(0)
        end
      end
      @velocity += Matrix[adjustment]
    end

    def apply_velocity()
      @position += @velocity
    end

    def energy()
      potential = @position.to_a.first.map{|pos| pos.abs}.reduce(:+)
      kinetic = @velocity.to_a.first.map{|pos| pos.abs}.reduce(:+)
      potential * kinetic
    end
  end
end
