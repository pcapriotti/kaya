module Chess

class PGN
  def initialize(serializer)
    @serializer = serializer
  end
  
  def write(info, history)
    date = if info[:date].respond_to? :strftime
      info[:date].strftime('%Y.%m.%d')
    else
      info[:date]
    end
    tag(:event, info[:event]) +
    tag(:site, info[:site]) +
    tag(:date, date) +
    tag(:round, info[:round]) +
    tag(:white, info.fetch(:players, {})[:white]) +
    tag(:black, info.fetch(:players, {})[:black]) +
    tag(:result, result(info[:result])) +
    game(history) + " " +
    result(info[:result]) + "\n"
  end
  
  def tag(key, value)
    if value
      %{[#{key.to_s.capitalize} "#{value}"]\n}
    else
      ""
    end
  end
  
  def result(value)
    case value
    when String
      value
    when :white
      "1-0"
    when :black
      "0-1"
    when :draw
      "1/2-1/2"
    else
      "*"
    end
  end
  
  def game(history)
    1.to_enum(:step, history.size - 1, 2).map do |i|
      wmove = @serializer.serialize(history[i].move, history[i - 1].state)
      bmove = if i + 1 < history.size
        @serializer.serialize(history[i + 1].move, history[i].state)
      end
      index = (i + 1) / 2
      result = "#{index}.#{wmove}"
      result += " #{bmove}" if bmove
      result
    end.join(' ')
  end
end

end
