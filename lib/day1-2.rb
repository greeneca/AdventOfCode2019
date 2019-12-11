module P12
  class P12
    def run(input)
      input.map!{|m| m.to_i}

      total = 0
      input.each {|weight|
        while weight > 0
          weight = fuelReq(weight)
          total += weight
        end
      }

      puts "Total: #{total}"
    end

    def fuelReq(weight)
      req = (weight/3.0).floor-2
      if req < 0
        req = 0
      end
      return req
    end
  end
end
