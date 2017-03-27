
class Asteroid
  attr_reader :x, :y, :radius

  def initialize(animation, asteroids, player)
    @animation = animation
    @color = Gosu::Color.argb(0xff_ffffff)
    @radius = animation.first.height / 2
    loop do
      @x = rand * 100 - 100
      @y = rand * 1200 - 900

      break unless asteroids.map { |asteroid| self.min_dist?(asteroid) }.include?(true)
    end
    # loop do
      # rand * 640
      # rand * 480
      # break unless (player.x - @x).abs > 200 && (player.y - @y).abs > 200
      # break unless asteroids.map { |asteroid| (asteroid.x - @x).abs > 50 && (asteroid.y - @y).abs > 50 }.include?(false)
    # end
  end

  def min_dist?(thing)
    dist = Gosu::distance(self.x, self.y, thing.x, thing.y)
    dist < (self.radius + thing.radius) + 70
  end


  def draw
    img = @animation[Gosu.milliseconds / 150 % (@animation.size/2.7)]
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::STARS, 1, 1, @color, :add)
  end
  def move
    angle = rand(80..165)
    @x += Gosu.offset_x(angle, rand * 2.5)
    @y += Gosu.offset_y(angle, rand * 2.5)
  end

  def far?
    self.x > 1280
  end
  def collide?(thing)
    dist = Gosu::distance(self.x, self.y, thing.x, thing.y)
    dist < (self.radius + thing.radius) - 20
  end
end

class AsteroidGroup < Asteroid
  attr_reader :x, :y, :radius

  def draw
    img = @animation[Gosu.milliseconds / 150 % (@animation.size/2.7)]
    img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
        ZOrder::STARS, 1, 1, @color, :add)
  end

  def move
    angle = rand(90..120)
    @x += Gosu.offset_x(angle, rand * 2 + 5)
    @y += Gosu.offset_y(angle, rand * 2 + 5)
  end

  def collide?(thing)
    dist = Gosu::distance(self.x, self.y, thing.x, thing.y)
    dist < (self.radius + thing.radius) - 50
  end
end
