module P61
  class P61
    def run(input)
      generate_system_map(input)
      puts "Checksum: #{calculate_checksum}"
    end

    def calculate_checksum
      checksum = 0
      @system_map.keys.each do |body|
        body = @system_map[body]
        while body.parent
          checksum += 1
          body = body.parent
        end
      end
      checksum
    end

    private

    def generate_system_map(input)
      @system_map = {}
      input.each do |map|
        parent, child = map.split(")").map{|s| s.strip}
        unless @system_map[parent]
          @system_map[parent] = OrbitingBody.new(parent)
        end
        if @system_map[child]
          @system_map[child].setParent(@system_map[parent])
        else
          @system_map[child] = OrbitingBody.new(child, @system_map[parent])
        end
      end
    end
  end

  class OrbitingBody

    attr_reader :name
    attr_reader :parent
    attr_reader :children

    def initialize(name, parent=nil)
      @name = name
      @children = []
      setParent(parent) if parent
    end

    def setParent(parent)
      @parent = parent
      @parent.addChild(self)
    end

    def addChild(child)
      @children.append(child)
    end
  end
end
