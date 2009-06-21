require 'animations'

module AnimatorHelper
  include Animations
  
  def move!(src, dst, path, opts = {})
    piece = board.move_item(src, dst)
    src = nil if opts[:adjust]
    movement(piece, src, dst, path)
  end
  
  def disappear_on!(p, opts = {})
    name = "disappear on #{p}"
    if opts[:instant]
      instant_disappear p, name
    else
      item = board.remove_item(p, :keep)
      disappear(item, name)
    end
  end
    
  def appear_on!(p, piece, opts = {})
    name = "appear #{piece} on #{p}"
    if opts[:instant]
      instant_appear p, piece, name
    else
      item = board.add_piece p, piece, :hidden => true
      appear(item, name)
    end
  end
  
  def morph_on!(p, piece, opts = {})
    name = "morph to #{piece} on #{p}"
    if opts[:instant]
      instant_appear p, piece, name
    else
      old_item = board.remove_item(p, :keep)
      new_item = board.add_piece p, piece, :hidden => true
      group appear(new_item, name + " (appear)"),
            disappear(old_item, name + " (disappear)")
    end
  end
end
