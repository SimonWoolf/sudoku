# module Kernel
#   def puts(n)
#   end
# end

require_relative 'cell'
# gem 'pry-byebug'

class Grid
  
  GROUPS = [:row, :column, :box]
  GROUP_INDEX = (1..9).to_a

  attr_accessor :cells

  def initialize(input)
    normalised_input = input_interpreter(input)
    raise "Invalid input" if !(normalised_input.length == 81)
    initialize_cells(normalised_input)
  end

  def self.deep_copy(instance)
    Grid.new(instance.to_s)
  end

  def initialize_cells(normalised_input)
    @cells = []
    GROUP_INDEX.each do |row|
      GROUP_INDEX.each do |column|
        value = normalised_input[(row-1)*9 + (column-1)].to_i
        @cells << Cell.new(row, column, value)
      end
    end
  end

  def input_interpreter(input)
    input.gsub(/[^0-9.]/,'').gsub(/\./,'0') # magic
  end

  def to_s
    cells.map{|cell| cell.to_s}.join('')
  end

  def cell_at(row, column)
    cells.find{|cell| cell.row == row && cell.column == column}
  end


  def group_candidates_for(current_cell, group)
    neighbours = cells.select{|cell| cell.send(group) == current_cell.send(group)}
    solved_neighbours = neighbours.select{|cell| cell.solved?}
    GROUP_INDEX - solved_neighbours.map{|cell| cell.value}
  end

  def candidates_for(current_cell)
    GROUPS.inject(GROUP_INDEX) do |candidates, group|
      candidates & group_candidates_for(current_cell, group)
    end
  end

  def solve_cell_at(row, column)
    solve_cell(cell_at(row, row))
  end

  def solve_cell(current_cell)
    possibilities = candidates_for(current_cell)
    if possibilities.length == 1
      current_cell.value = possibilities.first 
    end
  end

  def solve()
    if !valid?
      raise 'invalid'
    end
    while true
      solved_cells = solved_cell_count()
      cells.each{|cell| solve_cell(cell) if !cell.solved?}
      if solved_cells == solved_cell_count()
        guess_grid = Grid.deep_copy(self)
        guess_cell = guess_grid.cells.find { |cell| !cell.solved?}
        guess_candidates = candidates_for(guess_cell)
        print "BEFORE guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n"
        guess_candidates.each do |candidate|
          print "AFTER guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n\n"
          guess_cell.value = candidate
          return true if guess_grid.solve
        end
        return nil
      end
    end
    raise 'Generated invalid solution' unless valid?
  end


  def solved_cell_count
    cells.select {|cell| cell.solved?}.count
  end

  def valid?
    GROUPS.each do |group_type|
      GROUP_INDEX.each do |group_index|
        values_in_group = all_values_of(cells_in_group(group_index, group_type))
        return false if has_duplicates(values_in_group)
      end
    end
    true
  end
  
  def has_duplicates(values)
    values.delete(0)
    values.length != values.uniq.length
  end

  def cells_in_group(group_number, group_type)
    cells.select{|cell| cell.send(group_type) == group_number }
  end

  def all_values_of(cells)
    cells.inject([]){|values, cell| values << cell.value }
  end
end

