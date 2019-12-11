module P41
  class P41
    def run(input)
      values = input.first.split("-")
      valid_passwords = 0
      (values[0].to_i..values[1].to_i).each do |password|
        prev = -1
        has_adjacent = false
        all_incrementing = true
        password.to_s.split("").map{|d| d.to_i}.each do |digit|
          has_adjacent = has_adjacent || digit == prev
          if digit < prev
            all_incrementing = false
            break
          end
          prev = digit
        end
        if has_adjacent and all_incrementing
          valid_passwords += 1
        end
      end
      puts "Valid Passwords: #{valid_passwords}"
    end
  end
end
