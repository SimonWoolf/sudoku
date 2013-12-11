require 'sinatra'
require 'sinatra/partial' 
require_relative 'lib/grid'
set :partial_template_engine, :erb

enable :sessions  unless test?
set :session_secret, "not a secret"

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Grid.new(seed.join)
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) do |memo, i|
    memo += boxes[i/3*3, 3].map do |box| 
      box[(i % 3) * 3, 3]
    end.flatten
  end
end

def solved(sudoku)
  sudoku.solve
  sudoku
end

def generate_new_puzzle
  sudoku = random_sudoku
  session[:puzzle] = sudoku.to_s
  session[:solution] = solved(sudoku).to_s
  session[:proposed_solution] = nil
end

def prepare_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

get '/' do
  prepare_check_solution
  generate_new_puzzle if session[:puzzle].nil? || params[:new]
  @current_puzzle = session[:proposed_solution] || session[:puzzle]
  @current_puzzle = session[:solution] if params[:solution]
  @proposed_solution = session[:proposed_solution] || ''
  @puzzle = session[:puzzle]
  @solution = session[:solution]
  erb :index
end

post '/' do
  cells = box_order_to_row_order(params['cell'])
  session[:proposed_solution] = cells.map(&:to_i).join
  session[:check_solution] = true
  redirect to('/')
end

helpers do
  def colour_class(checking, puzzle_val, proposed_val, solution_val)
    if !checking || proposed_val.to_i == 0
      :unmodified
    elsif puzzle_val.to_i != 0 && proposed_val == puzzle_val
      :provided
    elsif puzzle_val.to_i != 0 && proposed_val != puzzle_val
      :modified_provided
    elsif proposed_val == solution_val
      :right
    else
      :wrong
    end
  end

  def cell_value(value)
    value.to_i == 0 ? '' : value
  end
end
