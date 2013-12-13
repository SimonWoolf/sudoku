require 'grid'

describe Grid do 
    let(:testinput){ 
     "+---+---+---+
      |...|8.9|...|
      |836|5..|17.|
      |45.|..3|.62|
      +---+---+---+
      |7.1|.4.|.9.|
      |36.|...|58.|
      |.2.|78.|4.1|
      +---+---+---+
      |1..|6.7|9..|
      |.92|...|..5|
      |.7.|.12|.43|
      +---+---+---+"
    }
    let(:grid){Grid.new(testinput)}
    let(:unsolved_cell){grid.cell_at(1, 1)}
    

  context 'initialization' do

    it 'should load a graphical input correctly' do
      expect(grid.to_s).to eq "000809000836500170450003062701040090360000580"\
                            + "020780401100607900092000005070012043"
    end

    it 'should raise an error if input is the wrong length' do
      expect {Grid.new("123...23445...")}.to raise_error(RuntimeError) 
    end

    it 'should know what its cells are' do
      expect(grid.cells.length).to eq(81) 
    end

    it 'should know when it is not solved' do
      expect(grid).not_to be_solved 
    end

    it 'should translate row 4, column 2 to linear zero-index 28' do
      expect(grid.row_col_to_index(4, 2)).to eq 28
    end
  end

  context 'should know the candidate values' do

    it "from its row, if not solved" do
      expect(grid.unit_candidates_for(unsolved_cell, :row).sort).to eq([1,2,3,4,5,6,7]) 
    end

    it "from its column, if not solved" do
      expect(grid.unit_candidates_for(unsolved_cell, :column).sort).to eq([2,5,6,9]) 
    end

    it "from its box, if not solved" do
      expect(grid.unit_candidates_for(unsolved_cell, :box).sort).to eq([1,2,7,9]) 
    end
  
    it 'for the current cell, if not solved' do
      expect(grid.candidates_for(unsolved_cell).sort).to eq([2]) 
    end
  end

  context 'solver' do
    it 'should be able to solve non-destructively' do
      solved_grid = grid.solve
      expect(solved_grid).to be_solved
      expect(grid).to_not be_solved
    end
  end

  context 'solve hard problems' do
    it 'should give a solution for an empty grid' do
      empty_grid = Grid.new('.'*81)
      empty_grid.solve!
      expect(empty_grid).to be_solved
    end

    it 'should solve a example problem' do
      grid = Grid.new(".....8........1..65.3...4...2....9.4....8...3.9.3...8...479......64...21......6..")
      grid.solve!
      expect(grid).to be_solved
    end
  end

  context 'multiple solutions' do
    it 'should work out all solutions if true is passed to solve' do
      grid = Grid.new("009870500124300009000040230201035097650900000000010065402060003080003600006701058")
      solutions_count = grid.num_solutions
      expect(solutions_count).to eq 4
    end

    it 'should return 1 for a proper sudoku' do
      expect(grid.num_solutions).to eq 1
    end
  end

  context 'validity checker' do
    it 'should return false for an incorrect solution' do
      bad_grid = Grid.new("794746223874651872635419371982736429313645192736491278346192635412937462398457456")
      expect(bad_grid).to_not be_valid
    end
  
    it 'should return false for an obviously invalid input' do
      invalid_input = Grid.new("1.. .1. ...  ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ... ")
      expect(invalid_input).to_not be_valid
    end

  end

  context 'grid deep-copier' do
   it 'should work' do
     old_grid = Grid.new(testinput)
     new_grid = Grid.deep_copy(old_grid)
     expect(old_grid.cell_at(1, 1).object_id).to_not \
      eq(new_grid.cell_at(1, 1).object_id)
    end
  end
end # of describe



