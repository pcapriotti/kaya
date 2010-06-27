# Copyright (c) 2010 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'toolkit'

class AutoReload  
  def self.start(basedir)
    if @notifier
      warn "AutoReload already started"
    else
      @notifier = new(File.expand_path(basedir))
    end
  end
  
  def initialize(basedir)
    @watch = KDE::DirWatch.new
    @watch.add_dir(basedir, KDE::DirWatch::WatchSubDirs)
    @watch.on(:dirty) do |filename|
      if filename =~ /\.rb$/
        warn "reloading #{filename}"
        begin
          load(filename)
        rescue Exception => e
          warn e
        end
      end
    end
  end
end
