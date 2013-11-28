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
    # Marshal.load(Marshal.dump(instance))
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

  def solve_cell_at(row, column)
    solve_cell(cell_at(row, row))
  end

  def solve_cell(current_cell)
    possibilities = candidates_for(current_cell)
    if possibilities.length == 1
      current_cell.value = possibilities.first 
      p "solved:" + current_cell.inspect
    end
  end

  def solve()
    puts "entering solve()"
    p self
    # raise 'Invalid input' unless valid?
    if !valid?
      puts "Depth: #{Kernel.caller.select{|l| l.match /solve/}.count}"

      puts 'following is invalid:'
      p self
      raise 'invalid'
    end
    while !solved?
      solved_cells = solved_cell_count()
      cells.each{|cell| solve_cell(cell) if !cell.solved?}
      if solved_cells == solved_cell_count()
        try = make_a_guess
        return nil if try.nil?
      end
      # if try.nil? #REMOVEME
      #   puts 'guessing returned nill'
      # end
    end
    raise 'Generated invalid solution' unless valid?
  end

  def make_a_guess
    # puts 'make a guess'
    puts "entering make_a_guess()"
    p self
    guess_grid = Grid.deep_copy(self)
    # puts guess_grid.cells[0].inspect
    guess_cell = guess_grid.cells.find { |cell| !cell.solved?}
    puts "Guess cell: #{guess_cell.object_id}: #{guess_cell.row}, #{guess_cell.column}. value: #{guess_cell.value.inspect}"
    # p guess_cell
    guess_candidates = candidates_for(guess_cell)
    puts "GUEST CANDIDATES:"
    puts guess_candidates.inspect + guess_candidates.object_id.to_s

    # print "before guess_candidates.each. Guess cell: #{guess_cell.object_id}: #{guess_cell.row}, #{guess_cell.column}. value: #{guess_cell.value.inspect}"
    print "BEFORE guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n"
    guess_candidates.each do |candidate|
      # puts "inside guest_candidates.each. guess candidates: #{guess_candidates} for #{guess_cell.object_id}: #{guess_cell.row}, #{guess_cell.column}"
      print "AFTER guest candidates objID: #{guess_candidates.object_id}, guess cell objID: #{guess_cell.object_id}\n"
      puts guess_candidates.inspect + guess_candidates.object_id.to_s
      # depth = Kernel.caller.select{|l| l.match /solve/}.count
      # puts "Depth: #{depth}"
      # puts guess_grid.inspect
      # return nil if guess_candidates.empty?
      # guess_cell.value = guess_candidates.shift
      # break unless guess_grid.solve == nil #Try another candidate if that one lead to a dead end
      guess_cell.value = candidate
      return true if guess_grid.solve
    end
    if guess_grid.solved?
      puts "Guess grid solved"
      self.cells = guess_grid.cells 
    end
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

  def inspect
    s = self.to_s
    depth = Kernel.caller.select{|l| l.match /solve/}.count
    puts " " * depth + "+---+---+---+"
    puts " " * depth + "|" + s[0..2] + '|' + s[3..5] + '|' + s[6..8] + '|' 
    puts " " * depth + "|" + s[9..11] + '|' + s[12..14] + '|' + s[15..17] + '|' 
    puts " " * depth + "|" + s[18..20] + '|' + s[21..23] + '|' + s[24..26] + '|' 
    puts " " * depth + "+---+---+---+"
    puts " " * depth + "|" + s[27..29] + '|' + s[30..32] + '|' + s[33..35] + '|' 
    puts " " * depth + "|" + s[36..38] + '|' + s[39..41] + '|' + s[42..44] + '|' 
    puts " " * depth + "|" + s[45..47] + '|' + s[48..50] + '|' + s[51..53] + '|' 
    puts " " * depth + "+---+---+---+"
    puts " " * depth + "|" + s[54..56] + '|' + s[57..59] + '|' + s[60..62] + '|' 
    puts " " * depth + "|" + s[63..65] + '|' + s[66..68] + '|' + s[69..71] + '|' 
    puts " " * depth + "|" + s[72..74] + '|' + s[75..77] + '|' + s[78..80] + '|' 
    puts " " * depth + "+---+---+---+"
  end
end

