
require_relative 'cell'
# gem 'pry-byebug'

class Grid
  
  GROUPS = [:row, :column, :box]
  GROUP_INDEX = (1..9).to_a

  attr_accessor :cells

  def initialize(input)
    normalised_input = input_interpreter(input)
    raise "Invalid input" if normalised_input.length != 81
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

  def solved?
    cells.all? {|cell| cell.solved?} && valid?
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

  def solve()
    raise "Invalid state #{self.inspect}" if !valid?
    while !solved?
      guess_grid = Grid.deep_copy(self)
      guess_cell, guess_candidates = cell_and_candidates_with_fewest_candidates_in(guess_grid)
      guess_candidates.each do |candidate|
        guess_cell.value = candidate
        guess_grid.solve # Recursive step
      end
      return guess_grid if !guess_grid.solved?
      self.cells = guess_grid.cells
    end
    raise "Generated invalid solution #{self.inspect}" unless valid?
  end

  def cell_and_candidates_with_fewest_candidates_in(guess_grid)
    cells_and_candidates = unsolved_cells_in(guess_grid).map do |cell|
      [cell, candidates_for(cell)]
    end
    cells_and_candidates.sort{|x, y| x[1].length <=> y[1].length}.first
  end

  def unsolved_cells_in(grid)
    grid.cells.select { |cell| !cell.solved? }
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

  def inspect
    horiz_splitter = "+---+---+---+"
    groups_of_three = self.to_s.scan(/.../)
    bars = '|'.*(27).split('')
    lines = bars.zip(groups_of_three).flatten
    eachline = (0..53).step(6).map{|i| "#{lines[i..i+5].join('')}|\n"}
    puts "#{horiz_splitter}\n#{(0..8).step(3).map{|i| "#{eachline[i..i+2].join('')}#{horiz_splitter}"}.join("\n")}"
  end
end

