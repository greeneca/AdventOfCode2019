module P122
  class P122
    def run(input)
      input.map!{|line| line.gsub(/<|>/, "").split(",").map{|n| n.gsub(/.*=/, "").to_i}}
      moons_initial = input.map{|pos| Moon.new(pos)}
      itterations = nil
      (0..2).each do |coordinate|
        moons = Marshal.load(Marshal.dump(moons_initial))
        i = 1
        while true
          if i > 1
            is_previous_state = true
            moons.each do |moon|
              is_previous_state = (moon.is_previous_state and is_previous_state)
            end
            if is_previous_state
              i -= 1
              puts "Coor: #{coordinate} iterates #{i}"
              if itterations
                itterations = (i/i.gcd(itterations)) * itterations
              else
                itterations = i
              end
              break
            end
          end
          moons.combination(2).each do |pair|
            pair.first.adjust_velocity(pair.last, coordinate)
            pair.last.adjust_velocity(pair.first, coordinate)
          end
          moons.each do |moon|
            moon.apply_velocity
          end
          i += 1
        end
      end
      puts "Itterations: #{itterations}"
    end
  end

  class Moon
    attr_reader :position, :states
    def initialize(position)
      @position = Matrix[position]
      @velocity = Matrix[[0,0,0]]
      @states = []
      save_state
    end

    def to_s
      state.to_s
    end

    def adjust_velocity(moon, coordinate)
      adjustment = []
      @position.each_with_index do |value, i, j|
        if coordinate != j or value  == moon.position[i, j]
          adjustment.push(0)
        elsif value > moon.position[i, j]
          adjustment.push(-1)
        elsif value < moon.position[i, j]
          adjustment.push(1)
        end
      end
      @velocity += Matrix[adjustment]
    end

    def apply_velocity
      @position += @velocity
      save_state
    end

    def energy()
      potential = @position.to_a.first.map{|pos| pos.abs}.reduce(:+)
      kinetic = @velocity.to_a.first.map{|pos| pos.abs}.reduce(:+)
      potential * kinetic
    end

    def save_state
      @states.push(Matrix.hstack(@position, @velocity))
    end

    def is_previous_state
      @states.first == state
    end

    def state
      Matrix.hstack(@position, @velocity)
    end
  end
end
