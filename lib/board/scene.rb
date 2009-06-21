require 'observer_utils'

class Scene < Qt::GraphicsScene
  MINIMAL_DRAG_DISTANCE = 3
  include Observer

  def initialize
    super
    
    @elements = []
  end

  def add_element(element)
    @elements << element
  end
  
  def mousePressEvent(e)
    if e.button == Qt::LeftButton
      pos = e.scene_pos.to_i
      if find_element(pos)
        @drag_data = { :pos => pos }
      end
    end
  end
  
  def mouseReleaseEvent(e)
    if e.button == Qt::LeftButton
      if @drag_data
        old_pos = @drag_data[:pos]
        item = @drag_data[:item]
        data = @drag_data
        @drag_data = nil
        
        pos = e.scene_pos.to_i
        element_src = find_element(old_pos)
        element_dst = find_element(pos)
        
        if data[:dragging]
          # normal drag and drop

          if element_dst.nil?
            # if the drop is in a blank area,
            # notify the source of the drop
            notify(element_src, :drop, [old_pos, nil], data)
          else
            src = if element_src == element_dst
              old_pos
            end
            notify(element_dst, :drop, [src, pos], data)
          end
        elsif element_src == element_dst
          # close drag and drop == click
          # the element will decide how to handle it based on the distance
          # between the coordinates
          notify(element_dst, :click, [old_pos, pos])
        else
          # a rapid drag and drop between different elements
          # is never considered a click
          notify(element_src, :drag, [old_pos])
          notify(element_src, :drop, [nil, pos], data)
        end
      end
    end
  end
  
  def mouseMoveEvent(e)
    if @drag_data
      pos = e.scene_pos.to_i
      if !@drag_data[:dragging]
        dx = (@drag_data[:pos].x - pos.x).abs
        dy = (@drag_data[:pos].y - pos.y).abs
        if dx >= MINIMAL_DRAG_DISTANCE ||
           dy >= MINIMAL_DRAG_DISTANCE
          @drag_data[:dragging] = true
          notify(find_element(pos), :drag, [@drag_data[:pos]])
        else
          return
        end
      end
      
      if @drag_data[:item]
        @drag_data[:item].pos = (pos - @drag_data[:size] / 2).to_f
      end
    end
  end
  
  def find_element(pos)
    @elements.detect do |element|
      element.rect.contains(pos)
    end
  end
  
  def notify(element, event, pos, *args)
    if element
      relpos = pos.map{|p| rel(element, p) }
      element.send("on_#{event}", *(relpos + args))
    end
  end
  
  def rel(element, pos)
    if pos
      pos - element.rect.top_left
    end
  end
  
  # invoked by the controller when one of the elements 
  # accepts a drag
  def on_drag(data)
    if @drag_data
      @drag_data = @drag_data.merge(data)
    end
  end
end
