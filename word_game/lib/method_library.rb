require 'open-uri'
require 'json'
require_relative "grid"
# ENGLISH_WORDS_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words.txt"
# ENGLISH_WORDS = open(ENGLISH_WORDS_URL).read.tr("\n", " ").split(" ").drop(50)

ENGLISH_WORDS = File.open("lib/text.txt").map { |l| l.delete!("\n") }

SCRABBLE_SCORES = {
  "A" => 1, "B" => 3, "C" => 3, "D" => 2,
  "E" => 1, "F" => 4, "G" => 2, "H" => 4,
  "I" => 1, "J" => 8, "K" => 5, "L" => 1,
  "M" => 3, "N" => 1, "O" => 1, "P" => 3,
  "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
  "U" => 1, "V" => 4, "W" => 4, "X" => 8,
  "Y" => 4, "Z" => 10
}

def scrabble_score(word)
  scrabble_score = 0
  word.upcase.each_char { |l| scrabble_score += SCRABBLE_SCORES[l] }
  return scrabble_score
end

def in_grid?(word, grid)
  grid_h = Hash.new(0)
  r = true
  grid.each { |x| grid_h[x] += 1 }
  word.upcase.chars.each { |l| grid_h[l] > 0 ? grid_h[l] -= 1 : r = false }
  return r
end

# Test
# p g = generate_grid(6)
# a = gets.chomp.upcase
# p in_grid?(a, g)

def english?(word)
  ENGLISH_WORDS.include?(word.downcase)
end


def score(time_elapsed, word)
  ((scrabble_score(word) / Math.log(time_elapsed + 1)) * 100).to_i
end


def message(word, time_elapsed, score, in_grid)
  if !in_grid
    "Your word is not in the grid!"
  elsif !english?(word)
    "Not an english word!"
  else
    "Well done!"
  end
end

def return_hash(time_elapsed, score, message)
  {
    time: time_elapsed,
    score: score,
    message: message
  }
end

def game_data(attempt, grid, start_time, end_time)
  attempt.upcase!
  time_elapsed = end_time - start_time
  in_grid = in_grid?(attempt, grid)
  score = english?(attempt) && in_grid ? score(time_elapsed, attempt) : 0
  message = message(attempt, time_elapsed, score, in_grid)
  return_hash(time_elapsed, score, message)
end
