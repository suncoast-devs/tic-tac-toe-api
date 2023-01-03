require "sinatra"
require "sinatra/json"
require "active_record"
require "json"
require "amazing_print"

set(:port, ENV["PORT"]) if ENV["PORT"]

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db.sqlite3',
)

ActiveRecord::Schema.define do
  create_table :games do |t|
    t.text :board
    t.string :winner, limit: 3
    t.timestamps
  end
end

configure do
  enable :cross_origin
end

before do
  response.headers["Access-Control-Allow-Origin"] = "*"
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"

  200
end

require_relative "./moves.rb"
require_relative "./game.rb"

get "/" do
  send_file File.join(settings.public_folder, "docs.html")
end

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
  data = nil

  begin
    data = JSON.parse(request.body.read)
  rescue JSON::ParserError
    halt 400, json(error: "Sorry, your JSON request could not be parsed")
  end

  id = params[:id]

  column = data["column"]
  row = data["row"]

  unless ["0", "1", "2"].include?(column.to_s)
    halt 400, json(error: "The value #{column || "null"} is invalid for the parameter column")
  end

  unless ["0", "1", "2"].include?(column.to_s)
    halt 400, json(error: "The value #{row || "null"} is invalid for the parameter row")
  end

  game = Game.find_by(id: id)
  unless game
    status 404
    return
  end

  if game.winner
    json(game)
    return
  end

  result = game.human_move(row.to_i, column.to_i)

  if result == :invalid
    status 400
    return
  end

  game.save

  json(game)
end
