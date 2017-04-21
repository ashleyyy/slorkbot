require 'benchmark'

def test_this

  message = "Ashley can't figure out Benchmark"
 
  action = message.split.first
  term = message.split(' ')[1..-1].join(' ')

  case action.downcase

  when 'thing'
    other thing
  when 'ashley'
     "Ashley is my creator! She needs for nothing, except maybe a full time jorb"
  when 'third thing'
    etc.
  else
    puts "guys, sometimes I need love too"
  end

end

def test_that

  message = "Ashley can't figure out Benchmark"
 
  action = message.split.first.downcase
  term = message.split(' ')[1..-1].join(' ')

  case action
  when 'thing'
    other thing
  when 'ashley'
     "Ashley is my creator! She needs for nothing, except maybe a full time jorb"
  when 'third thing'
    etc.
  else
    puts "guys, sometimes I need love too"
  end

end




iterations = 100_000

Benchmark.bmbm do |bm|
  # joining an array of strings
  bm.report do
    iterations.times do
      test_this
    end
  end

  # using string interpolation
  bm.report do
    iterations.times do
      test_that
    end
  end
end