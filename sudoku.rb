require 'sinatra'
require_relative 'lib/grid'

enable :sessions  unless test?

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Grid.new(seed.join)
  #sudoku.solve
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) do |memo, i|
    memo += boxes[i/3*3, 3].map do |box| 
      box[(i % 3) * 3, 3]
    end.flatten
  end
end

def generate_new_puzzle
  puzzle = random_sudoku.to_s
  session[:puzzle] = puzzle
  puzzle.gsub('0',' ')
end

get '/' do
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
  
  @current_puzzle = (session[:proposed_solution] || generate_new_puzzle).gsub('0',' ') 

  erb :index
end

post '/' do
  cells = box_order_to_row_order(params['cell'])
  session[:proposed_solution] = cells.map(&:to_i).join
  session[:check_solution] = true
  redirect to('/')
end

get '/solution' do
  puzzle = session[:puzzle]
  sudoku = Grid.new(puzzle)
  sudoku.solve
  @current_puzzle = sudoku.to_s
  erb :index
end
