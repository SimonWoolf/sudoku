require 'sinatra'

get '/' do
  @name = params[:name]
  erb :index, {:layout => :layout}
end
