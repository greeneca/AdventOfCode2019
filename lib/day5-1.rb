module P51
  class P51
    def run(input)
      input = input.first.split(",")
      input.map!{|i| i.to_i}
      runProgram(input)
    end

    private

    def performUnaryOp(op, pointer, paramModes)
      case op
      when :write
        target = @memmory[pointer]
        @memmory[target] = getInput()
      when :print
        printOutput(readValue(pointer, paramModes[0]))
      end
    end
    def performBinaryOp(op, pointer, paramModes)
      a = readValue(pointer, paramModes[0])
      b = readValue(pointer+1, paramModes[1])
      @memmory[@memmory[pointer+2]] = a.public_send(op, b)
    end

    def readValue(pointer, mode)
      mode ||= 0
      case mode
      when 0
        return @memmory[@memmory[pointer]]
      when 1
        return @memmory[pointer]
      end
    end

    def getInput()
      return 1
    end

    def printOutput(value)
      puts value
    end

    def parseOpCode(value)
      opCode = value%100
      value = value/100
      paramModes = value.to_s.split("").map{|v| v.to_i}
      return [opCode, paramModes.reverse]
    end

    def runProgram(memmory)
      @memmory = memmory
      pointer = 0
      while true
        opCode, paramModes = parseOpCode(memmory[pointer])
        case opCode
        when 1
          performBinaryOp(:+, pointer+1, paramModes)
          pointer += 4
        when 2
          performBinaryOp(:*, pointer+1, paramModes)
          pointer += 4
        when 3
          performUnaryOp(:write, pointer+1, paramModes)
          pointer +=2
        when 4
          performUnaryOp(:print, pointer+1, paramModes)
          pointer +=2
        when 99
          break
        else
          puts "Error Unknows op code #{memmory[pointer]}"
          exit
        end
      end
    end
  end
end


