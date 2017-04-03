class Grid

  attr_reader :grid
  def initialize(grid_size)
    # TODO: generate random grid of letters
    letters = []
    vowels = ["A", "E", "I", "O", "U"]
    SCRABBLE_SCORES.each do |l, x|
      1.upto(120 / x) do
        letters << l
      end
    end
    @grid = []
    1.upto(grid_size - 2) { @grid << letters.sample }
    2.times { @grid << vowels.sample }
    @grid.shuffle!
  end

  def show
    @grid
  end

  def to_s
    @grid.join(" ")
  end

  def shuffle
    @grid.shuffle!
  end
end
