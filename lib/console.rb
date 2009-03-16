require 'qtutils'

class Console < Qt::Widget
  include Observable

  def initialize(parent)
    super
    
    layout = Qt::VBoxLayout.new
    @output = Qt::TextEdit.new(self)
    @input = Qt::LineEdit.new(self)
    
    layout.add_widget(@output)
    layout.add_widget(@input)
    setLayout layout
    
    @output.read_only = true
    f = @output.font
    f.family = 'monospace'
    @output.font = f
    @output.current_font = f
    @bold_font = f
    @bold_font.bold = true

    @input.on(:returnPressed) do
      text = @input.text
      with_font(@bold_font) do
        @output.append text
      end
      @input.text = ''
      fire :input => text
    end
  end

  def with_font(font)
    old = @output.current_font
    @output.current_font = font
    yield
    @output.current_font = old
  end
  
  def append(text)
    @output.append(text)
  end
end
