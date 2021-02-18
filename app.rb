require "sinatra"
require "sinatra/json"
require "sinatra/activerecord"
require "json"
require "amazing_print"

if ENV["PORT"]
  set :port, ENV["PORT"]
end

if ENV["RACK_ENV"] != "production"
  set :database_file, "./config/database.yml"
end

require_relative "./moves.rb"
require_relative "./game.rb"

post "/game" do
  game = Game.new_game

  json(game)
end

get "/game/:id" do
  id = params[:id]
  game = Game.find_by(id: id)
  if game
    json(game)
  else
    status 404
  end
end

post "/game/:id" do
  request.body.rewind
  data = JSON.parse(request.body.read)

  id = params[:id]
  column = data["column"].to_i
  row = data["row"].to_i

  game = Game.find_by(id: id)
  unless game
    status 404
    return
  end

  if game.winner
    json(game)
    return
  end

  result = game.human_move(row, column)

  if result == :invalid
    status 400
    return
  end

  game.save

  json(game)
end
