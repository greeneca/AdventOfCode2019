module P21
  class P21
    def run(input)
      input = input.first.split(",")
      input.map!{|i| i.to_i}
      pointer = 0
      while true
        case input[pointer]
        when 1
          performOp(:+, input, pointer+1)
          pointer += 4
        when 2
          performOp(:*, input, pointer+1)
          pointer += 4
        when 99
          puts "Done: #{input[0]}"
          exit
        else
          puts "Error Unknows op code #{input[pointer]}"
          exit
        end
      end
    end

    private

    def performOp(op, input, pointer)
      a = input[input[pointer]]
      b = input[input[pointer+1]]
      input[input[pointer+2]] = a.public_send(op, b)
    end
  end
end
