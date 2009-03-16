require 'qtutils'

module ICS

# 
# A connection to an ICS server
# 
class Connection < Qt::Object
  attr_accessor :debug

  signals :hostFound, :established,
  'receivedLine(QString, int)',
  'receivedText(QString, int)'

  def initialize(host, port)
    super nil

    @create_socket = lambda do 
      puts "connecting to #{host}:#{port}"
      s = Qt::TcpSocket.new(self)
      connect(s, SIGNAL(:hostFound), self, SIGNAL(:hostFound))
      s.connect(s, SIGNAL(:connected), self, SIGNAL(:established))
      s.on(:readyRead) { process_line }
      s.connect_to_host(host, port)
      s
    end
  end

  def process_line
    puts "processing line"
    unless @socket
      puts "no socket!"
      return
    end
    
    while @socket.can_read_line
      line = @socket.read_line.to_s
      line = @buffer + line.gsub("\r", '')
      emit receivedLine(line, @buffer.size)
      @buffer = ''
    end

    if (size = @socket.bytes_available) > 0
      data = @socket.read_all
      offset = @buffer.size
      @buffer += data.to_s.gsub("\r", '')
      emit receivedText(@buffer, offset)
    end
    
  end

  def start
    @socket = @create_socket.call
    @connected = true
    @buffer = ''
  end

  def stop
  end

  def send_text(text)
    puts "> #{text}" if @debug
    unless @connected
      @unsent_text += @text + "\n"
      return
    end
    
    unless @socket
      puts "no socket!"
      return
    end
    
    process_line
    os = Qt::TextStream(@socket)
    os << text + "\n"
  end

  def on_received_line(&blk)
    connect(self, SIGNAL('receivedLine(QString, int)'), &blk)
  end

  def on_received_text(&blk)
    connect(self, SIGNAL('receivedText(QString, int)'), &blk)
  end
end

end
