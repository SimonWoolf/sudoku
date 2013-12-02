# module Kernel
#   def puts(n)
#   end
# end

require_relative 'cell'
# gem 'pry-byebug'

class Grid
  
  @@objectid

  GROUPS = [:row, :column, :box]
  GROUP_INDEX = (1..2).to_a

  attr_accessor :cells

  def initialize(input)
    @cells = [Cell.new(0, input[0].to_i),
              Cell.new(1, input[1].to_i)]
  end

  def self.deep_copy(instance)
    Grid.new(instance.to_s)
  end

  def to_s
    cells.map{|cell| cell.to_s}.join('')
  end

  def candidates_for(current_cell)
      [1,2] - cells.map{|cell| cell.value}
  end


  def solve()
    while true
      puts self
      guess_grid = Grid.deep_copy(self)
      guess_cell = guess_grid.cells.find { |cell| !cell.solved?}
      guess_candidates = candidates_for(guess_cell)
      @@objectid = guess_candidates.object_id
      print "BEFORE guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n"
      p guess_candidates
      guess_candidates.each do |candidate|
        print "AFTER guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n"
        p guess_candidates
        puts ""
        raise 'weird_error' if @@objectid != guess_candidates.object_id
        guess_cell.value = candidate
        guess_grid.solve
      end
      return nil
    end
  end
end

