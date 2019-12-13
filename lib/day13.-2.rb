module P132
  class P132
    def run(input)
      @player_mode = :ai
      program = input.first.split(",").map{|i| i.to_i}
      program[0] = 2
      screen = Hash.new(0)
      score = 0
      paddle_initial = nil
      paddle_position = nil
      ball_positions = []
      @itterations_count = 0
      @prev_block_count = 0
      @total_blocks = nil
      input = Proc.new {
        @total_blocks = screen.select{|k,v| v == 2}.count if @total_blocks == nil
        blocks = screen.select{|k,v| v == 2}.count
        if blocks != @prev_block_count
          @itterations_count = 0
          @prev_block_count = blocks
        else
          @itterations_count += 1
        end
        if @itterations_count > 1000
          @player_mode = :player
        end
        if @player_mode == :player
          printScreen(screen, score)
          input = STDIN.getch
          2.times do
            input += STDIN.getc
          end
          case input
          when "\e[D"
            -1
          when "\e[C"
            1
          when "\e[B"
            0
          when "\e[A"
            @player_mode = :ai
            0
          end
        elsif @player_mode == :ai
          printScreen(screen, score)
          if ball_positions.count > 1
            change = ball_positions[-1]-ball_positions[-2]
            next_position = ball_positions[-1] + change
            block_check = ball_positions.last + Matrix[[change[0,0], 0]]
            if screen[block_check] == 2 and change[0,1] > 0
              change = Matrix[[change[0,0]*-1, change[0,1]]]
              next_position = ball_positions[-1] + change
            end
            ball_x = ball_positions.last[0,0]
            ball_y = ball_positions.last[0,1]
            next_x = next_position[0,0]
            next_y =next_position[0,1]
            paddle_x = paddle_position[0,0]
            paddle_y = paddle_position[0,1]
            input = 0
            if @itterations_count > 200 and ball_y+1 == paddle_y
              if ball_x > paddle_x
                1
              elsif paddle_x > ball_x
                -1
              else
                0
              end
            elsif next_y > ball_y or ball_y > 15
              if next_x == paddle_x or (paddle_x == ball_x and paddle_y+1 == ball_y)
                input = 0
              elsif next_x > paddle_x
                input = 1
              elsif next_x < paddle_x
                input = -1
              end
            else
              if paddle_x > paddle_initial[0,0]
                input = -1
              elsif paddle_x < paddle_initial[0,0]
                input = 1
              end
            end
            input
          end
        end
      }
      mode = :x
      coordinates = []
      output = Proc.new {|value|
        case mode
        when :x
          coordinates.push(value)
          mode = :y
        when :y
          coordinates.push(value)
          mode = :tile
        when :tile
          if coordinates == [-1, 0]
            score = value
          else
            screen[Matrix[coordinates]] = value
            paddle_initial = Matrix[coordinates] if value == 3 and paddle_initial.nil?
            paddle_position = Matrix[coordinates] if value == 3
            ball_positions.push(Matrix[coordinates]) if value === 4
          end
          coordinates = []
          mode = :x
        end
      }
      arcade = IncodeComputer.new(program, input, output)
      arcade.runProgram
      printScreen(screen, score)
    end

    def printScreen(screen, score)
      max_x, max_y = 0, 0
      screen.each_key do |matrix|
        coor = matrix.to_a.first
        max_x = coor[0] if coor[0] > max_x
        max_y = coor[1] if coor[1] > max_y
      end
      system('clear')
      print_screen = ""
      (0..max_y).each do |y|
        (0..max_x).each do |x|
          print_screen += getTile(screen[Matrix[[x,y]]])
        end
        print_screen += "\n"
      end
      blocks = screen.select{|k,v| v == 2}.count
      print_screen += "Score: #{score}  Blocks: #{blocks}/#{@total_blocks}\n"
      print print_screen
    end

    def getTile(id)
      case id
      when 0
        " "
      when 1
        "&"
      when 2
        "#"
      when 3
        "-"
      when 4
        "o"
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
