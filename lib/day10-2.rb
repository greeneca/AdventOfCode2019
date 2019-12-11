module P102
  class P102
    def run(input)
      @sector = {}
      @height = input.count
      input.each_index do |y|
        row = input[y].split("")
        @width = row.count
        row.each_index do |x|
          if row[x] == "#"
            @sector[Matrix[[x, y]]] = Astroid.new(x, y)
          end
        end
      end
      @sector.each_value do |source|
        @sector.each_value do |target|
          source.checkObserval(target, @sector)
        end
      end
      #printSector
      @station = @sector.values.sort{|a,b|a.obserable <=> b.obserable}.last
      @sector.delete_if{|k,v| v == @station}
      calculateAngles
      sectorList = @sector.values.sort{|a,b| a.angle <=> b.angle}
      destroyed = []
      while @sector.count > 0
        toDestroy = []
        sectorList.each do |astroid|
          if @station.checkSightLine(astroid, @sector)
            toDestroy.push(astroid)
          end
        end
        destroyed += toDestroy
        sectorList.delete_if{|a| destroyed.include?(a)}
        @sector.delete_if{|k,v| destroyed.include?(v)}
      end
      guess = destroyed[199]
      guess = guess.x*100 + guess.y
      puts "Guess: #{guess}"
    end
    def printSector()
      (0..@height).to_a.each do |y|
        row = ""
        (0..@width).to_a.each do |x|
          if @sector[Matrix[[x, y]]]
            row += @sector[Matrix[[x, y]]].to_s + " "
          else
            row += ". "
          end
        end
        puts row
      end
    end
    def calculateAngles()
      @sector.values.each do |astroid|
        x = (astroid.x - @station.x).to_f
        y = (astroid.y - @station.y) * -1
        if x > 0
          if y > 0
            astroid.angle = Math.atan(x/y)
          elsif y == 0
            astroid.angle = Math::PI/2
          elsif y < 0
            astroid.angle = Math::PI + Math.atan(x/y)
          end
        elsif x == 0
          if y > 0
            astroid.angle = 0
          elsif y < 0
            astroid.angle = Math::PI
          end
        elsif x < 0
          if y < 0
            astroid.angle = Math::PI + Math.atan(x/y)
          elsif y == 0
            astroid.angle = (3*Math::PI)/2
          elsif y > 0
            astroid.angle = 2 * Math::PI + Math.atan(x/y)
          end
        end
      end
    end
  end

  class Astroid
    attr_reader :x, :y, :obserable
    attr_accessor :angle
    def initialize(x, y)
      @x = x
      @y = y
      @obserable = 0
      @angle = 0
    end
    def to_s
      @obserable.to_s
    end
    def checkObserval(astroid, sector)
      if checkSightLine(astroid, sector)
        @obserable += 1
      end
    end
    def checkSightLine(astroid, sector)
      #puts "======= Testing #{@x},#{@y} -> #{astroid.x},#{astroid.y}"
      if @x != astroid.x
        slope = (astroid.y-@y).to_f/(astroid.x-@x).to_f
        intercept = @y - (slope * @x)
        autoRange(@x,astroid.x) do |x|
          y = (slope*x) + intercept
          return false if astroidExists(x, y, sector)
        end
      elsif @y != astroid.y
        autoRange(@y,astroid.y) do |y|
          return false if astroidExists(@x, y, sector)
        end
      else
        return false
      end
      #puts "Can See #{@x},#{@y} -> #{astroid.x},#{astroid.y}"
      true
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
