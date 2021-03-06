
require_relative 'cell'
# gem 'pry-byebug'

class Grid
  
  UNITS = [:row, :column, :box]
  UNIT_INDEX = (1..9).to_a

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
    UNIT_INDEX.each do |row|
      UNIT_INDEX.each do |column|
        value = normalised_input[row_col_to_index(row, column)].to_i
        @cells << Cell.new(row, column, value)
      end
    end
  end

  def row_col_to_index(row, column)
    (row-1)*9 + (column-1)
  end

  def input_interpreter(input)
    input.gsub(/[^0-9.]/,'').gsub(/\./,'0') # magic
  end

  def to_s
    cells.map(&:to_s).join
  end

  def to_i
    0 # Convenient for solve() when all_solutions is false
  end

  def cell_at(row, column)
    cells.find{|cell| [cell.row, cell.column] == [row, column]}
  end

  def solved?
    cells.all?(&:solved?) && valid?
  end

  def unit_candidates_for(current_cell, unit)
    neighbours = cells.select{|cell| cell.send(unit) == current_cell.send(unit)}
    solved_neighbours = neighbours.select(&:solved?)
    UNIT_INDEX - solved_neighbours.map(&:value)
  end

  def candidates_for(current_cell)
    UNITS.inject(UNIT_INDEX) do |candidates, unit|
      candidates & unit_candidates_for(current_cell, unit)
    end
  end

  def num_solutions
    solve_recurser(true)
  end

  def solve!
    solve_recurser(false)
  end

  def solve
    grid = Grid.deep_copy(self)
    grid.solve!
  end

  def solve_recurser(all_solutions = false)
    raise "Invalid state #{self.inspect}" if !valid?
    solutions_count ||= 0
    if !solved?
      guess_grid = Grid.deep_copy(self)
      guess_cell, guess_candidates = cell_and_candidates_with_fewest_candidates_in(guess_grid)
      guess_candidates.each do |candidate|
        guess_cell.value = candidate
        solutions_count += guess_grid.solve_recurser(all_solutions).to_i # Recursive step
      end
      solutions_count += 1 if guess_grid.solved?
      self.cells = guess_grid.cells if guess_grid.solved? && !all_solutions
      return all_solutions ? solutions_count : self
    end
  end

  def cell_and_candidates_with_fewest_candidates_in(guess_grid)
    cells_and_candidates = unsolved_cells_in(guess_grid).map do |cell|
      [cell, candidates_for(cell)]
    end
    cells_and_candidates.sort{|x, y| x[1].length <=> y[1].length}.first
  end

  def unsolved_cells_in(grid)
    grid.cells.reject(&:solved?)
  end

  def valid?
    UNITS.each do |unit_type|
      UNIT_INDEX.each do |unit_index|
        values_in_unit = all_values_of(cells_in_unit(unit_index, unit_type))
        return false if has_duplicates(values_in_unit)
      end
    end
    true
  end
  
  def has_duplicates(values)
    values.delete(0)
    values.length != values.uniq.length
  end

  def cells_in_unit(unit_number, unit_type)
    cells.select{|cell| cell.send(unit_type) == unit_number }
  end

  def all_values_of(cells)
    cells.inject([]){|values, cell| values << cell.value }
  end

  def puzzle
    counter = 0
    loop do
      counter += 1
      attempt = try_puzzle(5)
      return attempt if attempt.num_solutions == 1
      raise 'failed to generate valid sudoku' if counter > 15
    end
  end

  def try_puzzle(removals_per_box)
    trypuzzle = Grid.deep_copy(self)
    (1..9).each do |box|
      trypuzzle.cells.select do |cell| 
        cell.box == box
      end.sample(removals_per_box).each do |cell| 
        cell.value = 0
      end
    end
    trypuzzle
  end

  def inspect
    horiz_splitter = "+---+---+---+"
    units_of_three = self.to_s.scan(/.../)
    bars = '|'.*(27).split('')
    lines = bars.zip(units_of_three).flatten
    eachline = (0..53).step(6).map{|i| "#{lines[i..i+5].join('')}|\n"}
    puts "#{horiz_splitter}\n#{(0..8).step(3).map{|i| "#{eachline[i..i+2].join('')}#{horiz_splitter}"}.join("\n")}"
  end
end

