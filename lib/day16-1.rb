module P161
  class P161

    PHASES = 100

    def run(input)
      input = input.first.split("").map{|i| i.to_i}
      PHASES.times do
        new_input = []
        input.count.times do |round|
          pattern = getPattern([0,1,0,-1], round+1)
          sum = 0
          input.each_with_index do |value, index|
            pattern_index = (index+1) % pattern.count
            sum += value * pattern[pattern_index]
          end
          new_input.push(sum.abs%10)
        end
        input = new_input
      end
      puts "Signal: #{input[0..7].join("")}"
    end

    def getPattern(pattern, count)
      new_pattern = []
      pattern.each do |value|
        count.times do
          new_pattern.push(value)
        end
      end
      new_pattern
    end
  end
end
