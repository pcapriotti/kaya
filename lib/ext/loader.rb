# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

begin
  require 'ext/extensions'
rescue LoadError => e
  warn "ERROR: could not load extension library, some features may be missing"
  warn e.message
end

$ext = $qApp.findChild(Qt::Object, "kaya extensions") if $qApp
fake = unless $ext
  # install fake implementations of the extension functions
  warn "Creating fake extension library"
  $ext = Qt::Object.new
  class << $ext
    def exp_blur(img, radius)
    end
  end
  true
end
$ext.metaclass_eval do
  define_method(:fake) { fake }
end

# conveniently install extension functions in the appropriate places

class Qt::Image
  def exp_blur(radius)
    $ext.exp_blur(self, radius)
  end
end
