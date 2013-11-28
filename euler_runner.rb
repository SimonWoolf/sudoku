require_relative 'lib/grid'

File.open('project_euler_problems.txt','r') do |f|
  1.times do
    input = f.read(98)[8..-1]
    grid = Grid.new(input)
    grid.solve
    puts grid.to_s[0..2]
  end
end