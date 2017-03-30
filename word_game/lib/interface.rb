require 'gosu'
require_relative "longest_word"
require_relative "grid"
require_relative "text_input"
PADDING = 20


module ZOrder
  BACKGROUND = 0
  GRID = 1
  MENU = 2
  UI = 3
end

class Window < Gosu::Window
  def initialize
    super 1280, 550
    self.caption = "Word Game"

    @background_image = Gosu::Image.new("media/CasualGamesBackgroundThin.png", tileable: true)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @grid = Grid.new(12)
    @letter_images = {}
    ("a".."z").each do |l|
      @letter_images[l] = Gosu::Image.new("media/scrabble-pngs/#{l}.png$_resized.png", tileable: true)
    end
    @attempt = TextField.new(self, @font, 500, 400)
    @cursor = Gosu::Image.new(self, "media/resize_cursor_white.png", false)
    @attempt_submitted = true
    @start_menu = true
    @start = false
    @start_time = Time.now

  end

  def update
    if !@attempt_submitted
      attempt
    elsif Gosu.button_down? Gosu::KB_RETURN
      @start_menu = true
    end

    if @start
      @grid = Grid.new(12)
      @attempt = TextField.new(self, @font, 500, 400)
      @attempt_submitted = false
      @start_menu = false
      @start = false
      @start_time = Time.now
    end
  end


  def attempt
    self.text_input = @attempt
    if Gosu.button_down? Gosu::KB_RETURN
      @end_time = Time.now
      @attempt_submitted = true
      self.text_input = nil
      @result = run_game(@attempt.text, @grid.show, @start_time, @end_time)
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    if !@attempt_submitted
      # welcome message  --  @font.draw("Welcome to the Word Game", 300, self.height / 4 , ZOrder::UI, 3, 3, 0xff_ffffff  )
      # @font.draw(@grid.to_s, 300, 1 * (self.height / 4) , ZOrder::UI, 3, 3, 0xff_ffffff  )
      @grid.show.each_with_index do |l, i|
        @letter_images[l.downcase].draw( 200 + i * 66, 1 * (self.height / 4) , ZOrder::UI, 1, 1, 0xff_ffffff  )
      end
      # This was the old code with the text box -- @attempt.draw
      @font.draw("Your Word:", @attempt.x - 250, @attempt.y - 5 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )

      @attempt.text.chars.each_with_index do |l, i|
        @letter_images[l.downcase].draw( 500 + i * 66, @attempt.y - 20 , ZOrder::UI, 1, 1, 0xff_ffffff  )
      end

      @font.draw("Timer: #{(Time.now - @start_time).to_i}", 1000, 40 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )

      # if I want to add a cursor -- @cursor.draw(mouse_x, mouse_y, 0)
    elsif !@start_menu
      sleep(0.1)
      @font.draw("Your word:"                                              , 300, 1 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @attempt.text.chars.each_with_index do |l, i|
        @letter_images[l.downcase].draw(                            500 + i * 66, 1 * (self.height / 8) + 70 , ZOrder::UI, 1, 1, 0xff_ffffff  )
      end
      @font.draw("Time taken: #{@result[:time].round(2)} seconds",           300, 2 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("Your score: #{@result[:score]}"                          , 300, 3 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("#{@result[:message]}"                                    , 300, 4 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
    end

    if @start_menu
      @cursor.draw(mouse_x, mouse_y, ZOrder::UI)

      @h_start = 130
      h = @h_start
      @w = 500
      @l = 280

      @font.draw("New Game", @w + @l / 4 - 60, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200,200,200,100)
      self.draw_quad(@w - PADDING      , h - PADDING         , c,
                     @w + @l + PADDING, h - PADDING         , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING, h + @font.height * 3 + PADDING, c, 0)
      @h_exit = @h_start + 150
      h = @h_exit
      @font.draw("Exit", @w + @l / 4 + 20, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200,200,200,100)
      self.draw_quad(@w - PADDING      , h - PADDING         , c,
                     @w + @l + PADDING, h - PADDING         , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING, h + @font.height * 3 + PADDING, c, 0)
    end
  end


  def start?(mouse_x, mouse_y)
    mouse_x > @w - PADDING       and mouse_x < @w + @l + PADDING and
    mouse_y > @h_start - PADDING and mouse_y < @h_start + @font.height + PADDING
  end

  def exit?(mouse_x, mouse_y)
    mouse_x > @w - PADDING      and mouse_x < @w + @l + PADDING and
    mouse_y > @h_exit - PADDING and mouse_y < @h_exit + @font.height + PADDING
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    else
      super
    end

    if id == Gosu::MsLeft
      @start = start?(mouse_x, mouse_y)
      close if exit?(mouse_x, mouse_y)
    end
  end

end

Window.new.show
