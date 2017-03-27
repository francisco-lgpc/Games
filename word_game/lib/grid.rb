class Grid

  attr_reader :grid
  def initialize(grid_size)
    # TODO: generate random grid of letters
    letters = []
    SCRABBLE_SCORES.each do |l, x|
      1.upto(120 / x) do
        letters << l
      end
    end
    @grid = []
    1.upto(grid_size) { @grid << letters.sample }
  end

  def show
    @grid
  end

  def to_s
    @grid.join(" ")
  end
end
