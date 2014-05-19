ENV['RACK_ENV'] = 'test'

require 'rack/test'
require_relative '../sudoku'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

describe 'helper functions' do
  it 'should convert box order to row order' do
    box_order = [1, 2, 3, 10, 11, 12, 19, 20, 21, 4, 5, 6, 13, 14, 15, 22, 23, 24, 7, 8, 9, 16, 17, 18, 25, 26, 27, 28, 29, 30, 37, 38, 39, 46, 47, 48, 31, 32, 33, 40, 41, 42, 49, 50, 51, 34, 35, 36, 43, 44, 45, 52, 53, 54, 55, 56, 57, 64, 65, 66, 73, 74, 75, 58, 59, 60, 67, 68, 69, 76, 77, 78, 61, 62, 63, 70, 71, 72, 79, 80, 81]
    expect(box_order_to_row_order(box_order)).to eq (1..81).to_a
  end

  it 'puzzlify then solve should get you back to where you started' do
    sudoku = random_sudoku.solve
    sudoku_puzzle = sudoku.puzzle
    expect(sudoku_puzzle.solve.to_s).to eq(sudoku.to_s)
  end
end

describe 'sudoku app' do
  def app
    Sinatra::Application
  end

  it "should generate a new puzzle on first load, setting cookies accordingly" do
    session = {}
    get '/', {}, {'rack.session' => session}
    expect(session[:puzzle].length).to eq(81)
    expect(session[:solution].length).to eq(81)
    expect(session[:check_solution]).to be_nil
    expect(session[:proposed_solution]).to be_nil
  end


  it "should set the night cookie if night button pressed" do
    session = {}
    post '/', {:night => ''}, {'rack.session' => session}
    expect(session[:night]).to be_true
  end

  it 'should show the correct & incorrect values in a'\
     'proposed solution if check_solution is set' do
  end

  it "should return eser-entered values as a cell array" do
    
  end
end
