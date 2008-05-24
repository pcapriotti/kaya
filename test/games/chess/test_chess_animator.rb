require 'test/unit'
require 'games/chess/animator'
require 'board/item_bag'

class TestChessAnimator < Test::Unit::TestCase
  class FakeBoard
    include ItemBag
    attr_reader :items
    
    def initialize(items)
      @items = items
    end
    
    def add_piece(p, piece, opts = {})
      add_item p, piece
    end
    
    def create_item(key, piece)
      piece
    end
    
    def destroy_item(piece)
    end
  end
  
  class FakeAnimation
    attr_reader :animation, :args
    def initialize(animation, args)
      @animation = animation
      @args = args
    end
    
    def <=>(other)
      animation.to_s <=> other.animation.to_s
    end
    
    def to_s
      "#{animation}(#{args.join(', ')}"
    end
  end

  def setup
    @chess = Chess::Game.new
    @items = {
      Point.new(3, 4) => @chess.new_piece(:white, :king),
      Point.new(3, 1) => @chess.new_piece(:black, :king),
      Point.new(7, 7) => @chess.new_piece(:black, :queen)
    }
    @board = FakeBoard.new(@items)
    
    @animator = @chess.new_animator(@board)
    class << @animator
      def self.stub_methods(*methods)
        methods.each do |method|
          eval %{
            def #{method}(*args)
              FakeAnimation.new(:#{method}, args)
            end
          }
        end
      end
      stub_methods :group, :appear, :disappear, :instant_appear, :instant_disappear
    end
    @state = @chess.new_state
  end
  
  def test_null_warp
    @state.board[Point.new(3, 4)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state)
    assert_animation(:group, anim) do |args|
      assert_equal [], args
    end
  end
  
  def test_simple_warp
    @state.board[Point.new(4, 3)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state)
    assert_animation(:group, anim) do |args|
      assert_equal 2, args.size
      
      appear, disappear = args.sort
      assert_animation :instant_appear, appear
      assert_animation :instant_disappear, disappear
    end
  end
  
  def test_simple_noninstant_warp
    @state.board[Point.new(4, 3)] = @chess.new_piece(:white, :king)
    @state.board[Point.new(3, 1)] = @chess.new_piece(:black, :king)
    @state.board[Point.new(7, 7)] = @chess.new_piece(:black, :queen)
    
    anim = @animator.warp(@state, :instant => false)
    assert_animation(:group, anim) do |args|
      assert_equal 2, args.size
      
      appear, disappear = args.sort
      assert_animation :appear, appear
      assert_animation :disappear, disappear
    end    
  end
  
  private
  
  def assert_animation(type, x)
    assert_equal type, x.animation
    yield x.args if block_given?
  end
end
