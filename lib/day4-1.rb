def p41(input)
  values = input.first.split("-")
  valid_passwords = 0
  (values[0].to_i..values[1].to_i).each do |password|
    last = -1
    has_adjacent = false
    all_incrementing = true
    password.to_s.split("").map{|d| d.to_i}.each do |digit|
      if digit == last
        has_adjacent = true
      end
      if digit >= last
        last = digit
      else
        all_incrementing = false
        break
      end
    end
    if has_adjacent and all_incrementing
      valid_passwords += 1
    end
  end
  puts "Valid Passwords: #{valid_passwords}"
end
