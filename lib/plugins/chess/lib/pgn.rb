# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'strscan'
require 'interaction/history'
require 'qtutils'

module Chess

class PGN
  ParseError = Class.new(ParseException)
  
  def initialize(serializer, state_factory)
    @serializer = serializer
    @state_factory = state_factory
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
    player_tags(info[:players] || { }) +
    tag(:result, result(info[:result])) +
    "\n" +
    game(history) + " " +
    result(info[:result]) + "\n"
  end
  
  def read(text, info)
    # read tags
    scanner = StringScanner.new(text)
    while scanner.scan(/\[(.*) "(.*)"\]\n/)
      info[scanner[1].downcase.to_sym] = scanner[2]
    end
    scanner.scan(/\n*/)
    
    # insert players into info[:players]
    info[:players] = read_players(info)
    
    state = @state_factory.new
    state.setup
    history = History.new(state)
    index = 1
    
    while scanner.scan(/(\d+)\.\s*/)
      if index != scanner[1].to_i
        raise ParseError.new("Unexpected index #{index}")
      end
      
      wmove = @serializer.deserialize(scanner, state)
      raise ParseError.new("Expected move at index #{index}") unless wmove
      state = state.dup
      state.perform! wmove
      history.add_move(state, wmove)
            
      scanner.scan(/\s+/)
      bmove = @serializer.deserialize(scanner, state)
      break unless bmove
      state = state.dup
      state.perform! bmove
      history.add_move(state, bmove)
      
      scanner.scan(/\s+/)
      
      index += 1
    end
    
    result = scanner.scan(/1-0|0-1|1\/2-1\/2|\*/)
    info[:result] = result if result
    history
  end
  
  def tag(key, value)
    if value
      %{[#{key.to_s.capitalize} "#{value}"]\n}
    else
      ""
    end
  end
  
  def read_players(info)
    result = {
      :white => info[:white],
      :black => info[:black] }
    info.delete(:white)
    info.delete(:black)
    result
  end
  
  def player_tags(players)
    tag(:white, players[:white]) +
    tag(:black, players[:black])
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
