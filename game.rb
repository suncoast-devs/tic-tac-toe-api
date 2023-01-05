require "active_record"

EMPTY_BOARD = [
  [" ", " ", " "],
  [" ", " ", " "],
  [" ", " ", " "],
]

WINNING_SPACES =
  [
    # Horizontal
    [[0, 0], [0, 1], [0, 2]],
    [[1, 0], [1, 1], [1, 2]],
    [[2, 0], [2, 1], [2, 2]],

    # Vertical
    [[0, 0], [1, 0], [2, 0]],
    [[0, 1], [1, 1], [2, 1]],
    [[0, 2], [1, 2], [2, 2]],

    # Diagonal
    [[0, 0], [1, 1], [2, 2]],
    [[0, 2], [1, 1], [2, 0]],
  ]

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db.sqlite3'
)

ActiveRecord::Schema.define do
  create_table :games do |t|
    t.text :board
    t.string :winner, limit: 3
    t.timestamps
  end
end

class Game < ActiveRecord::Base
  serialize :board, Array

  def self.new_game
    Game.create(board: EMPTY_BOARD)
  end

  def check_win
    self.winner = "X" if WINNING_SPACES.any? { |spaces| spaces.all? { |row, col| self.board[row][col] == "X" } }
    self.winner = "O" if WINNING_SPACES.any? { |spaces| spaces.all? { |row, col| self.board[row][col] == "O" } }
    self.winner = "TIE" if self.winner.nil? && self.board.flatten.count(' ') == 0
  end

  def human_move(row, column)
    return :invalid if self.board[row][column] != " "

    self.board[row][column] = "O"

    check_win

    return :valid if self.winner

    computer_move = GAME_MOVES.find { |move, boards| boards.include?(self.board) }

    return :valid unless computer_move

    computer_row = computer_move[0][:row]
    computer_col = computer_move[0][:col]

    self.board[computer_row][computer_col] = "X"

    check_win

    return :valid
  end
end
