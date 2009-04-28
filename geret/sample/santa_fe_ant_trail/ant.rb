
class Ant

  Food = '*'
  Empty = '.'

  Left = { :north => :west, :west => :south, :south => :east, :east => :north }
  Right = { :north => :east, :east => :south, :south => :west, :west => :north }
  DirX = { :north => 0, :west => -1, :south => 0, :east => 1 } 
  DirY = { :north => -1, :west => 0, :south => 1, :east => 0 }

  def initialize
    @grid = []
    IO.read( 'trail.txt' ).each { |line| @grid << line.split( // ) }
    @grid_height = @grid.size
    @grid_width = @grid.max { |line| line.size }

    @dir = :south
    @x, @y = 0, 0
    @consumed_food = 0
  end

  attr_reader :consumed_food, :x, :y, :dir

  def move
    @x, @y = ahead_x, ahead_y  
    next unless @grid[@y][@x] == Food
    @consumed_food += 1
    @grid[@y][@x] = Empty
  end

  def right
    @dir = Right[ @dir ]
  end

  def left
    @dir = Left[ @dir ]
  end

  def food_ahead
    Food == @grid[ ahead_y ][ ahead_x ]
  end

  protected

  def ahead_x
    ( @x + DirX[@dir] ).divmod( @grid_width ).last
  end

  def ahead_y
    ( @y + DirY[@dir] ).divmod( @grid_height ).last
  end

end

