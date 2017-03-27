require 'gosu'
require_relative 'player'
require_relative 'star'
require_relative 'asteroid'
require_relative 'zorder'



class Game < Gosu::Window
  def initialize
    super 1280, 720
    self.caption = "Space Game"

    @background_image = Gosu::Image.new("media/resize2_space.png", tileable: true)

    @player = Player.new
    @player.warp(320, 240)

    @star_anim = Gosu::Image.load_tiles("media/star.png", 25, 25)
    @stars = Array.new
    @font = Gosu::Font.new(20)

    @asteroid_anim = Gosu::Image.load_tiles("media/asteroid1.png", 72, 72)
    @asteroid_small_anim = Gosu::Image.load_tiles("media/resize2_asteroid.png", 150, 200)
    @asteroids = Array.new
    @asteroids_group = Array.new

    @n = 0
    @game_over = false
  end

  def colisions_any?
    @asteroids.map { |asteroid| asteroid.collide?(@player) }.include?(true) || \
    @asteroids_group.map { |asteroid| asteroid.collide?(@player) }.include?(true)
  end

  def update
    unless @game_over
      if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
        @player.turn_left
      end
      if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
        @player.turn_right
      end
      if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
        @player.accelerate
      end
      @player.move
      @player.collect_stars(@stars)

      if rand(100) < 4 and @stars.size < 25
        @stars.push(Star.new(@star_anim))
      end

      if rand * 100 < 2 + @n / 5000.0 and @asteroids.size < 10 + @n / 1000.0
        @asteroids << Asteroid.new(@asteroid_anim, @asteroids, @player)
      end

      if rand * 100 < 0.5 and @asteroids_group.size < 7
        @asteroids_group << AsteroidGroup.new(@asteroid_small_anim, @asteroids, @player)
      end
      @asteroids.each do |asteroid|
        asteroid.move
        @asteroids.delete(asteroid) if asteroid.far?
      end
      @asteroids_group.each do |asteroid|
        asteroid.move
        @asteroids_group.delete(asteroid) if asteroid.far?
      end
      if colisions_any?
        @game_over = true
      end
      @n += 1
    end
  end

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    @player.draw
    @stars.each { |star| star.draw }
    @asteroids.each { |asteroid| asteroid.draw }
    @asteroids_group.each { |asteroid| asteroid.draw }
    @font.draw("Score #{@player.score} | Level #{ @n / 1000 + 1}", 10, 10, \
               ZOrder::UI, 1.7, 1.7, Gosu::Color.argb(0xff_0000ff))
    if @game_over
      draw_game_over_screen
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  def draw_game_over_screen
    @font.draw("Game Over", self.width / 2 - 225, self.height / 2 - 100, ZOrder::BACKGROUND, 4.0, 4.0, 0xff_ffffff)
    @font.draw("Your score #{@player.score} | Level #{ @n / 1000 + 1}", self.width / 2 - 310, self.height / 2, ZOrder::UI, 3.0, 3.0, 0xff_ffffff)
  end
end

# Game.new.show

