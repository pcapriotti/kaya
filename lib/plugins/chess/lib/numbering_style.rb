# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Chess

class NumberingStyle
  def self.format_move(i, move)
    count = (i + 1) / 2
    dots = if i % 2 == 1
      '.'
    else
      '...'
    end
    
    "#{count}#{dots} #{move}"
  end
end

end
