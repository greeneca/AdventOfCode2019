module P92
  class P92
    def run(input)
      program = input.first.split(",").map{|i| i.to_i}
      comp = IncodeComputer.new(program)
      comp.runProgram
    end
  end

  class IncodeComputer

    attr_reader :output

    def initialize(memmory)
      @memmory = memmory
      @pointer = 0
      @relative_base = 0
      @output = 0
    end

    def runProgram()
      while true
        opCode, paramModes = parseOpCode(@memmory[@pointer])
        case opCode
        when 1
          performBinaryOp(:+, paramModes)
        when 2
          performBinaryOp(:*,  paramModes)
        when 3
          performUnaryOp(:write, paramModes)
        when 4
          performUnaryOp(:print, paramModes)
        when 5
          performJump(:!=, paramModes)
        when 6
          performJump(:==, paramModes)
        when 7
          performBinaryOp(:<, paramModes)
        when 8
          performBinaryOp(:==, paramModes)
        when 9
          performUnaryOp(:offset, paramModes)
        when 99
          break
        else
          puts "Error Unknows op code #{memmory[pointer]}"
          exit
        end
      end
    end

    private

    def parseOpCode(value)
      opCode = value%100
      value = value/100
      paramModes = value.to_s.split("").map{|v| v.to_i}
      return [opCode, paramModes.reverse]
    end

    def performUnaryOp(op, paramModes)
      case op
      when :write
        target = getMemmoryLocation(@pointer+1, paramModes[0])
        @memmory[target] = getInput()
      when :print
        printOutput(readValue(@pointer+1, paramModes[0]))
      when :offset
        @relative_base += readValue(@pointer+1, paramModes[0])
      end
      @pointer += 2
    end
    def getInput()
      2
    end
    def printOutput(value)
      puts value
    end

    def performBinaryOp(op, paramModes)
      a = readValue(@pointer+1, paramModes[0])
      b = readValue(@pointer+2, paramModes[1])
      @memmory[getMemmoryLocation(@pointer+3, paramModes[2])] = a.public_send(op, b).to_i
      @pointer += 4
    end

    def performJump(op, paramModes)
      check = readValue(@pointer+1, paramModes[0])
      if check.send(op, 0)
        @pointer = readValue(@pointer+2, paramModes[1])
      else
        @pointer += 3
      end
    end

    def readValue(pointer, mode)
      memmory_location = getMemmoryLocation(pointer, mode)
      return @memmory[memmory_location] || 0
    end

    def getMemmoryLocation(pointer, mode)
      mode ||= 0
      memmory_location = pointer
      case mode
      when 0
        memmory_location = @memmory[pointer]
      when 1
        memmory_location = pointer
      when 2
        memmory_location = @memmory[pointer]+@relative_base
      end
      if memmory_location < 0
        puts "FATAL: Invalid memmory Accecss: #{memmory_location}"
        exit
      end
      return memmory_location
    end
  end
end

class TrueClass; def to_i; return 1; end; end;
class FalseClass; def to_i; return 0; end; end;
