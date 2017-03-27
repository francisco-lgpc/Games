require 'gosu'
require_relative "longest_word"
require_relative "grid"
require_relative "text_input"

module ZOrder
  BACKGROUND = 0
  GRID = 1
  LETTER = 2
  UI = 3
end

class Window < Gosu::Window
  def initialize
    super 1280, 720
    self.caption = "Word Game"

    @background_image = Gosu::Image.new("media/2000px-Solid_black.svg.png", tileable: true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @grid = Grid.new(15)


    @attempt = TextField.new(self, @font, 500, 500)
    # if I want to add a cursor --  @cursor = Gosu::Image.new(self, "media/resize_cursor_white.png", false)
    @attempt_submitted = false
    @start_time = Time.now
  end

  def update
    if !@attempt_submitted
      attempt
    end
  end


  def attempt
    self.text_input = @attempt
    if Gosu.button_down? Gosu::KB_ENTER
      @end_time = Time.now
      @attempt_submitted = true
      self.text_input = nil
      @result = run_game(@attempt.text, @grid.show, @start_time, @end_time)
    end
  end



  def draw
    if !@attempt_submitted
      @background_image.draw(0, 0, ZOrder::BACKGROUND)
      # welcome message  --  @font.draw("Welcome to the Word Game", 300, self.height / 4 , ZOrder::UI, 3, 3, 0xff_ffffff  )
      @font.draw(@grid.to_s, 300, 1 * (self.height / 4) , ZOrder::UI, 3, 3, 0xff_ffffff  )
      @attempt.draw
      @font.draw("Your Word:", @attempt.x - 250, @attempt.y - 5 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )
      # if I want to add a cursor --  @cursor.draw(mouse_x, mouse_y, 0)
    else
      @font.draw("Your word: #{@attempt.text}"            , 300, 1 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("Time Taken to answer: #{@result[:time]}", 300, 2 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("Your score: #{@result[:score]}"         , 300, 3 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("Message: #{@result[:message]}"          , 300, 4 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      # Escape key will not be 'eaten' by text fields; use for deselecting.
      if self.text_input
        self.text_input = nil
      else
        close
      end
    elsif id == Gosu::MsLeft
      # Advanced: Move caret to clicked position
      self.text_input.move_caret(mouse_x) unless self.text_input.nil?
    end
  end

end

Window.new.show


=begin
puts "******** Welcome to the longest word-game !********"
puts "Here is your grid :"
grid = generate_grid(9)
puts grid.join(" ")
puts "*****************************************************"

puts "What's your best shot ?"
start_time = Time.now
attempt = gets.chomp.upcase
end_time = Time.now

puts "******** Now your result ********"

result = run_game(attempt, grid, start_time, end_time)

puts "Your word: #{attempt}"
puts "Time Taken to answer: #{result[:time]}"
puts "Translation: #{result[:translation]}"
puts "Your score: #{result[:score]}"
puts "Message: #{result[:message]}"

puts "*****************************************************"

=end
