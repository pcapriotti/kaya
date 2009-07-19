# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Some of the code in this file is extracted from the ptools library
# Copyright (C) 2003-2007 Daniel J. Berger
# The ptools library is distributed under the same terms as Ruby.

class File

   if RUBY_PLATFORM.match('mswin')
      IS_WINDOWS = true
      begin
         WIN32EXTS = ENV['PATHEXT'].split(';').map{ |e| e.downcase }
      rescue
         WIN32EXTS = %w/.exe .com .bat/
      end
   else
      IS_WINDOWS = false
   end



  # Looks for the first occurrence of +program+ within +path+.
  # 
  # On Windows, it looks for executables ending with the suffixes defined
  # in your PATHEXT environment variable, or '.exe', '.bat' and '.com' if
  # that isn't defined, which you may optionally include in +program+.
  #
  # Returns nil if not found. 
  #
  def self.which(program, path=ENV['PATH'])
     programs = program.to_a
     
     # If no file extension is provided on Windows, try the WIN32EXT's in turn
     if IS_WINDOWS && File.extname(program).empty?
        unless WIN32EXTS.include?(File.extname(program).downcase)
           WIN32EXTS.each{ |ext|
              programs.push(program + ext)
           }
        end
     end
     
     # Catch the first path found, or nil
     location = catch(:done){
        path.split(File::PATH_SEPARATOR).each{ |dir|
           programs.each{ |prog|
              f = File.join(dir, prog)
              if File.executable?(f) && !File.directory?(f)
                 location = File.join(dir, prog)
                 location.tr!('/', File::ALT_SEPARATOR) if File::ALT_SEPARATOR
                 throw(:done, location)
              end
           }
        }
        nil # Evaluate to nil if not found
     }
      location
  end

end
