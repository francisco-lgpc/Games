class GameOver < Gosu::Window
  def initialize
    @background_image = Gosu::Image.new("media/space.png", tileable: true)
    @font = Gosu::Font.new(20)
  end

  def update
  end


  def draw
    @background_image = Gosu::Image.new("media/space.png", tileable: true)

    @font.draw("Game Over", 0, 0, \
               ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)

    sleep(2)
    close
  end



end
