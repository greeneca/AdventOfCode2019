module P62
  class P62
    def run(input)
      generate_system_map(input)
      you_path = calculate_path_to_com("YOU")
      san_path = calculate_path_to_com("SAN")
      total = you_path + san_path
      total.delete_if{|b| you_path.include?(b) and san_path.include?(b)}
      puts "Transfer Count: #{total.count}"
    end

    def calculate_path_to_com(from)
      path = []
      body = @system_map[from]
      while body.parent
        path.push(body.name)
        body = body.parent
      end
      path.shift
      path
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
