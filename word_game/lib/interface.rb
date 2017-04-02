require 'gosu'
require_relative "method_library"
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

    @background_image  = Gosu::Image.new("media/CasualGamesBackgroundThin.png", tileable: true)
    @font              = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @cursor            = Gosu::Image.new(self, "media/resize_cursor_white.png", false)
    set_letter_png
    @attempt           = TextField.new(self, @font, 500, 400)
    @name              = TextField.new(self, @font, 500, 400)
    @attempt_submitted = true
    @start_menu        = true
    @game_mode_menu    = false
    @result_screen     = false
    @start             = false
    @start_time        = Time.now
    @screen_intact     = false
    @n                 = 1
    @score_total       = 0
    @storing_highscore = false
  end

  def set_letter_png
    @letter_images    = {}

    ("a".."z").each do |l|
      @letter_images[l] = Gosu::Image.new("media/scrabble-pngs/#{l}.png$_resized.png", tileable: true)
    end
  end

  def attempt
    self.text_input = @attempt

    if Gosu.button_down? Gosu::KB_RETURN and !@screen_intact
      @end_time          = Time.now
      @attempt_submitted = true
      self.text_input    = nil
      @result            = game_data(@attempt.text, @grid.show, @start_time, @end_time)
      @result_screen     = true
      @score_total      += @result[:score]
      @screen_intact     = true
    end
  end

  def store_new_highscore
    name = @name.text == "" ? "ANONYMOUS" : @name.text
    data = csv_to_arr
    round_data = [name, @score_total]
    data.insert(new_highscore?(@score_total) - 1, round_data)
    load_data(data)
  end

  def input_name
    self.text_input = @name
  end

  def update
    if !@attempt_submitted
      attempt
    else
      if !@screen_intact and Gosu.button_down? Gosu::KB_RETURN
        @result_screen      = false
        @screen_intact      = true
        @total_score_screen = false
        if @n_total > @n
          @start         = true
          @n            += 1
        elsif @n_total > 1
          @total_score_screen = true
          @n_total            = 1
          @n                  = 1
        elsif new_highscore?(@score_total) and !@storing_highscore
          input_name
          @storing_highscore = true
        else
          store_new_highscore if new_highscore?(@score_total)
          @start_menu         = true
          @score_total        = 0
          @storing_highscore  = false
        end
      end

      if @start
        @grid              = Grid.new(12)
        @attempt           = TextField.new(self, @font, 500, 400)
        @name              = TextField.new(self, @font, 500, 400)
        @attempt_submitted = false
        @start_menu        = false
        @game_mode_menu    = false
        @result_screen     = false
        @start             = false
        @start_time        = Time.now
      end
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    if !@attempt_submitted
      # welcome message:  @font.draw("Welcome to the Word Game", 300, self.height / 4 , ZOrder::UI, 3, 3, 0xff_ffffff  )
      # @font.draw(@grid.to_s, 300, 1 * (self.height / 4) , ZOrder::UI, 3, 3, 0xff_ffffff  )
      @grid.show.each_with_index do |l, i|
        @letter_images[l.downcase].draw( 200 + i * 66, 1 * (self.height / 4) , ZOrder::UI, 1, 1, 0xff_ffffff  )
      end
      # This was the old code with the text box: @attempt.draw
      @font.draw("Your Word:", @attempt.x - 250, @attempt.y - 5 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )

      @attempt.text.chars.each_with_index do |l, i|
        @letter_images[l.downcase].draw( 500 + i * 66, @attempt.y - 20 , ZOrder::UI, 1, 1, 0xff_ffffff  ) if !@letter_images[l.downcase].nil?
      end

      @font.draw("Timer: #{(Time.now - @start_time).to_i}", 1000, 40 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )

      @font.draw("Score: #{@score_total}",               20,   40 , ZOrder::UI, 2.5, 2.5, 0xff_ffffff  )
      # if I want to add a cursor: @cursor.draw(mouse_x, mouse_y, 0)
    elsif @result_screen
      @font.draw("Your word:",                                               300, 1 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @attempt.text.chars.each_with_index do |l, i|
        @letter_images[l.downcase].draw(                            500 + i * 66, 1 * (self.height / 8) + 70 , ZOrder::UI, 1, 1, 0xff_ffffff  )
      end
      @font.draw("Time taken: #{@result[:time].round(2)} seconds",           300, 2 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("Your score: #{@result[:score]}",                           300, 3 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @font.draw("#{@result[:message]}",                                     300, 4 * (self.height / 8) + 80 , ZOrder::UI, 2, 2, 0xff_ffffff  )
    elsif @total_score_screen
      @font.draw("FINAL SCORE #{@score_total}",                              300, 3 * (self.height / 8)      , ZOrder::UI, 4, 4, 0xff_ffffff  )
    elsif new_highscore?(@score_total)
      @font.draw("FINAL SCORE #{@score_total}",                              300, 3 * (self.height / 8) - 100, ZOrder::UI, 4, 4, 0xff_ffffff  )
      @font.draw("Please type your name:",                                   100, @name.y - 10               , ZOrder::UI, 2, 2, 0xff_ffffff  )
      @name.text.chars.each_with_index do |l, i|
        @letter_images[l.downcase].draw( 500 + i * 66, @name.y - 20 , ZOrder::UI, 1, 1, 0xff_ffffff  ) if !@letter_images[l.downcase].nil?
      end
    end

    if @start_menu
      @cursor.draw(mouse_x, mouse_y, ZOrder::UI)

      @h_option_1 = 130
      h = @h_option_1
      @w = 300
      @l = 280

      @font.draw("New Game", @w + @l / 4 - 60, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200, 200, 200, 100)
      self.draw_quad(@w - PADDING      , h - PADDING                   , c,
                     @w + @l + PADDING , h - PADDING                   , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING , h + @font.height * 3 + PADDING, c, 0)
      @h_option_2 = @h_option_1 + 150
      h = @h_option_2
      @font.draw("Exit", @w + @l / 4 + 20, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200, 200, 200, 100)
      self.draw_quad(@w - PADDING      , h - PADDING                   , c,
                     @w + @l + PADDING , h - PADDING                   , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING , h + @font.height * 3 + PADDING, c, 0)

      h = @h_option_1 - 50
      w = @w + 500
      l = @l + 100
      @font.draw("Leaderboard", w + l / 4 - 60, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )

      csv_to_arr.first(10).each_with_index do |round_data, i|
        spacing_1 = 2 - (i + 1).to_s.length
        spacing_2 = 17 - round_data[0].length
        @font.draw("#{i + 1}"        , w + l / 4 - 60 , h + 64 + i * 34, ZOrder::MENU, 1.5, 1.5, 0xff_ffffff  )
        @font.draw("#{round_data[0]}", w + l / 4 - 10 , h + 64 + i * 34, ZOrder::MENU, 1.5, 1.5, 0xff_ffffff  )
        @font.draw("#{round_data[1]}", w + l / 4 + 160, h + 64 + i * 34, ZOrder::MENU, 1.5, 1.5, 0xff_ffffff  )
      end


      c = Gosu::Color.rgba(200, 200, 200, 100)
      self.draw_quad(w - PADDING      , h - PADDING                   , c,
                     w + l + PADDING  , h - PADDING                   , c,
                     w - PADDING      , h + 400 + PADDING             , c,
                     w + l + PADDING  , h + 400 + PADDING             , c, 0)
    end

    if @game_mode_menu
      @cursor.draw(mouse_x, mouse_y, ZOrder::UI)

      @h_option_1 = 130
      h = @h_option_1
      @w = 500
      @l = 280

      @font.draw("One Word",   @w + @l / 4 - 50, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200, 200, 200, 100)
      self.draw_quad(@w - PADDING      , h - PADDING                   , c,
                     @w + @l + PADDING , h - PADDING                   , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING , h + @font.height * 3 + PADDING, c, 0)
      @h_option_2 = @h_option_1 + 150
      h = @h_option_2
      @font.draw("Five Words", @w + @l / 4 - 65, h , ZOrder::MENU, 3, 3, 0xff_ffffff  )
      c = Gosu::Color.rgba(200, 200, 200, 100)
      self.draw_quad(@w - PADDING      , h - PADDING                   , c,
                     @w + @l + PADDING , h - PADDING                   , c,
                     @w - PADDING      , h + @font.height * 3 + PADDING, c,
                     @w + @l + PADDING , h + @font.height * 3 + PADDING, c, 0)
    end
  end

  def Option_1?(mouse_x, mouse_y)
    mouse_x > @w - PADDING       && mouse_x < @w + @l + PADDING &&
    mouse_y > @h_option_1 - PADDING && mouse_y < @h_option_1 + @font.height + PADDING
  end

  def Option_2?(mouse_x, mouse_y)
    mouse_x > @w - PADDING      && mouse_x < @w + @l + PADDING &&
    mouse_y > @h_option_2 - PADDING && mouse_y < @h_option_2 + @font.height + PADDING
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    else
      super
    end

    if id == Gosu::MsLeft
      if @start_menu
        if Option_1?(mouse_x, mouse_y)
          @game_mode_menu = true
          return @start_menu = false
        end
        close if Option_2?(mouse_x, mouse_y)
      end

      if @game_mode_menu
        if Option_1?(mouse_x, mouse_y) || Option_2?(mouse_x, mouse_y)
          @start          = true
          @game_mode_menu = false
        end
        @n_total = 1 if Option_1?(mouse_x, mouse_y)
        @n_total = 5 if Option_2?(mouse_x, mouse_y)
      end
    end
  end

  def button_up(id)
    if id == Gosu::KB_RETURN
      @screen_intact = false
    end
  end

end
