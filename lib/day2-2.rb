module P22
  class P22
    def run(input)
      input = input.first.split(",")
      input.map!{|i| i.to_i}
      a = 0
      b = 0
      while true
        a += 1
        if a > 100
          a = 0
          b += 1
          if b > 100
            puts "Overflow"
            exit
          end
        end
        memmory = input.clone
        memmory[1] = a
        memmory[2] = b
        output = runProgram(memmory)
        if output == 19690720
          puts "Done: #{a}, #{b}"
          exit
        end
      end
    end

    private

    def performOp(op, memmory, pointer)
      a = memmory[memmory[pointer]]
      b = memmory[memmory[pointer+1]]
      memmory[memmory[pointer+2]] = a.public_send(op, b)
    end

    def runProgram(memmory)
      pointer = 0
      while true
        case memmory[pointer]
        when 1
          performOp(:+, memmory, pointer+1)
          pointer += 4
        when 2
          performOp(:*, memmory, pointer+1)
          pointer += 4
        when 99
          return memmory[0]
        else
          puts "Error Unknows op code #{memmory[pointer]}"
          exit
        end
      end
    end
  end
end
