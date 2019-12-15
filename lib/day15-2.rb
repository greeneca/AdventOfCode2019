module P151
  class P151
    def run(input)
      mode = :ai
      program = input.first.split(",").map{|i| i.to_i}
      @map = {}
      @position = Matrix[[0,0]]
      @map[@position] = 1
      change = Matrix[[0,0]]
      @moves_made = []
      prev_move = nil
      input = Proc.new {
        input = 0
        printMap
        if mode == :player
          input = STDIN.getch
          2.times do
            input += STDIN.getc
          end
          case input
          when "\e[A"
            change = Matrix[[0,-1]]
            input = 1
          when "\e[B"
            change = Matrix[[0,1]]
            input = 2
          when "\e[D"
            change = Matrix[[-1,0]]
            input = 3
          when "\e[C"
            change = Matrix[[1,0]]
            input = 4
          end
        elsif mode == :ai
          moves = [[1, Matrix[[0,-1]]], [2, Matrix[[0,1]]], [3, Matrix[[-1,0]]], [4, Matrix[[1,0]]]]
          moves.shuffle!
          move_to_make = nil
          moves.each do |move|
            if @map[@position + move[1]].nil?
              prev_move = move
              move_to_make = move
              break
            end
          end
          unless move_to_make
            prev_move = nil
            move_to_make = inverse(@moves_made.pop)
          end
          input = move_to_make[0]
          change = move_to_make[1]
        end
        input
      }
      output = Proc.new {|value|
        case value
        when 0
          @map[@position+change] = 0
        when 1
          @moves_made.push(prev_move) if prev_move
          @position += change
          @map[@position] = 1
        when 2
          @moves_made.push(prev_move) if prev_move
          @map[@position+change] = 2
          @position += change
          mode = :player
        end
      }
      arcade = IncodeComputer.new(program, input, output)
      arcade.runProgram
      printMap
    end

    def inverse(move)
      new_move = []
      case move[0]
      when 1
        new_move.push(2)
      when 2
        new_move.push(1)
      when 3
        new_move.push(4)
      when 4
        new_move.push(3)
      end
      new_move.push(Matrix[move[1].to_a.first.map{|x| x*-1}])
      new_move
    end

    def printMap
      max_x, max_y = 10, 10
      min_x, min_y = -10, -10
      @map.each_key do |matrix|
        coor = matrix.to_a.first
        max_x = coor[0] if coor[0] > max_x
        min_x = coor[0] if coor[0] < min_x
        max_y = coor[1] if coor[1] > max_y
        min_y = coor[1] if coor[1] < min_y
      end
      system('clear')
      print_screen = ""
      (min_y..max_y).each do |y|
        (min_x..max_x).each do |x|
          print_screen += getTile(Matrix[[x,y]])
        end
        print_screen += "\n"
      end
      print print_screen
      puts "Moves Made: #{@moves_made.count}"
    end

    def getTile(position)
      if position == Matrix[[0,0]]
        "X"
      elsif @map[position] and @map[position] == 2
        "O"
      elsif @position == position
        "D"
      elsif @map[position] and @map[position] == 0
        "#"
      elsif @map[position] and @map[position] == 1
        "."
      else
        " "
      end
    end
  end

  class IncodeComputer

    def initialize(memmory, input, output)
      @memmory = memmory
      @pointer = 0
      @relative_base = 0
      @input = input
      @output = output
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
      @input.call
    end
    def printOutput(value)
      @output.call(value)
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
