module P162
  class P162

    PHASES = 100

    #Not Working. Not sure why. Not going to fix it.
    def run(input)
      input = input.first
      new_input =""
      10000.times do
        new_input += input
      end
      input = new_input
      puts "Running FFT"
      PHASES.times do |phase|
        puts "Phase: #{phase}"
        input = fft(input)
      end
      position_start = input[0..7].to_i
      puts "Signal: #{input[position_start..position_start+7]}"
      byebug
    end

    def fft(input)
      sums = []
      sums.push(0)
      input.split("").each_with_index do |value, index|
        sums.push(sums[index]+value.to_i)
      end
      output = ""
      input.split("").each_with_index do |value, index|
        total = 0
        step = index + 1
        segment_index = step
        while(segment_index <= input.length)
          total += get_segment(segment_index, segment_index+step-1, sums)
          total -= get_segment(segment_index+(2*step), segment_index+(3*step)-1, sums)
          segment_index += step * 4
        end
        total = total.abs % 10
        output += total.to_s
      end
      output
    end

    def get_segment(seg_start, seg_end, sums)
      seg_start = 0 if seg_start < 1
      seg_start = sums.count-1 if seg_start >= sums.count
      seg_end = sums.count-1 if seg_end >= sums.count
      sums[seg_end]-sums[seg_start-1]
    end
  end
end
