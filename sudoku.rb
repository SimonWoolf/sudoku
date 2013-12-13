require 'sinatra'
require 'sinatra/partial' 
require_relative 'lib/grid'
set :partial_template_engine, :erb
configure :production do require 'newrelic_rpm' end

#TODO: Grid#puzzle sometimes gives a puzzle that has
#multiple solutions
# - make new a POST request???

enable :sessions  unless test?
set :session_secret, "not a secret"


def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  Grid.new(seed.join)
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
  sudoku = random_sudoku.solve
  session[:solution] = sudoku.to_s
  session[:puzzle] = sudoku.puzzle.to_s
  session[:proposed_solution] = nil
end

def prepare_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

def process_proposed_solution
  cells = box_order_to_row_order(params['cell'])
  session[:proposed_solution] = cells.map(&:to_i).join
  session[:check_solution] = true
end

def load_solution
  session[:proposed_solution] = session[:solution]
end

get '/' do
  prepare_check_solution
  generate_new_puzzle if session[:puzzle].nil?
  @current_puzzle = session[:proposed_solution] || session[:puzzle]
  @proposed_solution = session[:proposed_solution] || ''
  @puzzle = session[:puzzle]
  @solution = session[:solution]
  erb :index
end

post '/' do
  generate_new_puzzle if params[:new]
  process_proposed_solution if params[:cell]
  load_solution if params[:solution]
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
