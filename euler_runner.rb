require_relative 'lib/grid'

sum = 0

File.open('project_euler_problems.txt','r') do |file|
  50.times do |i|
    input = file.read(98)[8..-1]
    grid = Grid.new(input)
    puts "Solving problem #{i}..."
    grid.solve
    sum += grid.to_s[0..2].to_i
    puts sum
  end
end