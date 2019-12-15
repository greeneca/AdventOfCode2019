module P141
  class P141
    def run(input)
      reactions = {}
      input.each do |reaction|
        inputs, output = reaction.strip.split("=>")
        inputs  = inputs.strip.split(",").map{|ingredient| process_ingredient(ingredient)}
        output = process_ingredient(output)
        reactions[output[1]] = Reaction.new(output, inputs)
      end
      requirements = [[1, :FUEL]]
      while not done(requirements)
        requirements = requirements.inject([]) do |new_requirements,requirement|
          if reactions[requirement[1]]
            new_requirements += reactions[requirement[1]].get_requirements(requirement[0])
          else
            new_requirements.push(requirement)
          end
        end
        requirements = combine(requirements)
      end
      puts "Ore: #{requirements.first.first}"
    end

    def done(requirements)
      requirements.count == 1 and requirements[0][1] == :ORE
    end

    def process_ingredient(ingredient_string)
      ingredient = ingredient_string.strip.split(" ")
      ingredient[0] = ingredient[0].to_i
      ingredient[1] = ingredient[1].to_sym
      ingredient
    end

    def combine(requirements)
      new_requirements = Marshal.load(Marshal.dump(requirements.uniq{|req| req.last}))
      new_requirements.map! do |requirement|
        matching_requirements = requirements.select{|req| req[1] == requirement[1]}
        requirement[0] = matching_requirements.inject(0) {|sum,req| sum += req[0]}
        requirement
      end
      new_requirements
    end

  end

  class Reaction
    def initialize(creates, inputs)
      @creates = creates[1]
      @create_count = creates[0]
      @inputs = inputs
      @extra = 0
    end
    def get_requirements(count)
      count -= @extra
      reaction_count = (count.to_f/@create_count).ceil
      @extra = (@create_count*reaction_count) - count
      requirements = Marshal.load(Marshal.dump(@inputs))
      requirements.map do |input|
        input[0] *= reaction_count
        input
      end
    end
  end
end
