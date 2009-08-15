# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require_bundle 'chess', 'piece'

module Crazyhouse

module Promotable
  attr_accessor :promoted
  
  def actual_type
    if @promoted
      :pawn
    else
      type
    end
  end
end

class Piece < Chess::Piece
  include Promotable
end

end
