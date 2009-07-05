# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module ICS

module Config
  def self.config
    KDE::Global.config.group("ICS")
  end
  
  def self.load
    c = config
    { :username => c.read_entry('username', 'guest'),
      :password => c.read_entry('password', '') }
  end
  
  def self.save(data)
    c = config
    c.write_entry('username', data[:username])
    c.write_entry('password', data[:password])
    c.sync
  end
end

end
