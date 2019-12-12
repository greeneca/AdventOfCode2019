module P72
  class P72
    def run(input)
      program = input.first.split(",").map{|i| i.to_i}
      max_output = 0
      (5..9).to_a.permutation.each do |settings|
        amps = []
        settings.each do |phase|
          amps.push(Amplifier.new(program.dup, phase))
        end
        amps.each_index do |idx|
          amps[idx].input_amp = amps[idx-1]
          output = idx+1 >= amps.count ? 0 : idx +1
          amps[idx].output_amp = amps[output]
        end
        amps.first.runProgram
        if amps.last.output > max_output
          max_output = amps.last.output
        end
      end
      puts "Output: #{max_output}"
    end
  end

  class Amplifier

    attr_reader :output
    attr_accessor :input_amp
    attr_accessor :output_amp

    def initialize(memmory, phase)
      @memmory = memmory
      @pointer = 0
      @phase = phase
      @input_step = :phase
      @output = 0
      @input_amp = nil
      @output_amp = nil
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
        when 99
          break
        else
          puts "Error Unknows op code #{memmory[pointer]}"
          exit
        end
      end
    end

    def to_s
      @phase.to_s
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
        target = @memmory[@pointer+1]
        @memmory[target] = getInput()
        @pointer += 2
      when :print
        printOutput(readValue(@pointer+1, paramModes[0]))
      end
    end
    def getInput()
      case @input_step
      when :phase
        @input_step = :input
        return @phase
      when :input
        return @input_amp.output
      end
    end
    def printOutput(value)
      @output = value
      @pointer += 2
      @output_amp.runProgram
    end

    def performBinaryOp(op, paramModes)
      a = readValue(@pointer+1, paramModes[0])
      b = readValue(@pointer+2, paramModes[1])
      @memmory[@memmory[@pointer+3]] = a.public_send(op, b).to_i
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
      mode ||= 0
      case mode
      when 0
        return @memmory[@memmory[pointer]]
      when 1
        return @memmory[pointer]
      end
    end
  end
end

class TrueClass; def to_i; return 1; end; end;
class FalseClass; def to_i; return 0; end; end;
