# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module FileWriter
  def write_file(url, text)
    return nil if url.is_empty
    if url.is_local_file
      File.open(url.path, 'w') do |f|
        f.puts text
      end
    else
      tmp_file = KDE::TemporaryFile.new
      begin
        return nil unless tmp_file.open
        File.open(tmp_file.file_name, 'w') do |f|
          f.puts text
        end
        return nil unless KIO::NetAccess.upload(tmp_file.file_name, url, self)
      ensure
        tmp_file.close
      end
    end
    url
  end
end