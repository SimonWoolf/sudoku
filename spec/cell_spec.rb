# require 'cell'
# require 'grid'

# testinput = "000809000836500170450003062701040090360000580"\
#                             + "020780401100607900092000005070012043"

# describe Cell do

#   let(:grid){Grid.new(testinput)}
  
  
#   it 'should know which row it is in' do
#     expect(grid.cell_at(row:5, column:7).row).to eq(5) 
#   end

#   it "should know its value" do
#     expect(grid.cell_at(row:5, column:7).value).to eq(5) 
#   end

#   it 'should know what box it\'s in' do
#     expect(grid.cell_at(row:1, column:9).box).to eq(3)
#   end

#   it 'should know if its solved' do
#     expect(grid.cell_at(row:1, column:1).solved?).to be_false
#     expect(grid.cell_at(row:1, column:6).solved?).to be_true
#   end

# end