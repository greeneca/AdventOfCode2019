module P101
  class P101
    def run(input)
      @sector = {}
      input.each_index do |y|
        row = input[y].split("")
        row.each_index do |x|
          if row[x] == "#"
            @sector[Matrix[[x, y]]] = Astroid.new(x, y)
          end
        end
      end
      @sector.each_value do |source|
        @sector.each_value do |target|
          source.checkSightLine(target, @sector)
        end
      end
      #printSector
      puts @sector.values.sort{|a,b|a.obserable <=> b.obserable}.last.obserable
    end
    def printSector()
      (0..19).to_a.each do |y|
        row = ""
        (0..19).to_a.each do |x|
          if @sector[Matrix[[x, y]]]
            row += @sector[Matrix[[x, y]]].to_s + " "
          else
            row += ". "
          end
        end
        puts row
      end
    end
  end

  class Astroid
    attr_reader :x, :y, :obserable
    def initialize(x, y)
      @x = x
      @y = y
      @obserable = 0
    end
    def to_s
      @obserable.to_s
    end
    def checkSightLine(astroid, sector)
      #puts "======= Testing #{@x},#{@y} -> #{astroid.x},#{astroid.y}"
      if @x != astroid.x
        slope = (astroid.y-@y).to_f/(astroid.x-@x).to_f
        intercept = @y - (slope * @x)
        autoRange(@x,astroid.x) do |x|
          y = (slope*x) + intercept
          return if astroidExists(x, y, sector)
        end
      elsif @y != astroid.y
        autoRange(@y,astroid.y) do |y|
          return if astroidExists(@x, y, sector)
        end
      else
        return
      end
      #puts "Adding #{@x},#{@y} -> #{astroid.x},#{astroid.y}"
      @obserable += 1
    end
    def astroidExists(x, y, sector)
      x = x.round(3)
      y = y.round(3)
      #puts "Check: #{x},#{y}"
      return false unless x.to_i == x
      return false unless y.to_i == y
      if not sector[Matrix[[x.to_i, y.to_i]]].nil?
        #puts "Found at #{x},#{y}"
        return true
      end
      return false
    end
    def autoRange(a, b, &block)
      if a > b
        (b+1..a-1).each(&block)
      else
        (a+1..b-1).each(&block)
      end
    end
  end
end
