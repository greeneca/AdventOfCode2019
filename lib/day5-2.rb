class P52
  def run(input)
    input.map!{|program| program.split(",").map{|i| i.to_i}}
    input.each_index do |idx|
      puts "Running Program: #{idx}"
      runProgram(input[idx])
    end
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
    return pointer + 1
  end
  def performBinaryOp(op, pointer, paramModes)
    a = readValue(pointer, paramModes[0])
    b = readValue(pointer+1, paramModes[1])
    @memmory[@memmory[pointer+2]] = a.public_send(op, b).to_i
    return pointer + 3
  end
  def performJump(op, pointer, paramModes)
    check = readValue(pointer, paramModes[0])
    if check.send(op, 0)
      return readValue(pointer+1, paramModes[1])
    else
      return pointer + 2
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

  def getInput()
    return 5
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
        pointer = performBinaryOp(:+, pointer+1, paramModes)
      when 2
        pointer = performBinaryOp(:*, pointer+1, paramModes)
      when 3
        pointer = performUnaryOp(:write, pointer+1, paramModes)
      when 4
        pointer = performUnaryOp(:print, pointer+1, paramModes)
      when 5
        pointer = performJump(:!=, pointer+1, paramModes)
      when 6
        pointer = performJump(:==, pointer+1, paramModes)
      when 7
        pointer = performBinaryOp(:<, pointer+1, paramModes)
      when 8
        pointer = performBinaryOp(:==, pointer+1, paramModes)
      when 99
        break
      else
        puts "Error Unknows op code #{memmory[pointer]}"
        exit
      end
    end
  end
end

class TrueClass; def to_i; return 1; end; end;
class FalseClass; def to_i; return 0; end; end;
