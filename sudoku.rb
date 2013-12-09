require 'sinatra'
require_relative 'lib/grid'

enable :sessions

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Grid.new(seed.join)
  #sudoku.solve
end

get '/' do
  puzzle = random_sudoku.to_s
  session[:puzzle] = puzzle
  @current_puzzle = puzzle.gsub('0',' ')
  erb :index
end

get '/solution' do
  puzzle = session[:puzzle]
  sudoku = Grid.new(puzzle)
  sudoku.solve
  @current_puzzle = sudoku.to_s
  erb :index
end
