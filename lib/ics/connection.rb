require 'qtutils'

module ICS

# 
# A connection to an ICS server
# 
class Connection < Qt::Object
  attr_accessor :debug

  signal_map(:hostFound => nil,
             :established => nil,
             :received_line => 'receivedLine(QString)',
             :received_text => 'receivedText(QString)')

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
    unless @socket
      puts "no socket!"
      return
    end
    
    while @socket.can_read_line
      line = @socket.read_line.to_s
      line = @buffer + line.gsub("\r", '')
      line.chomp!
      emit receivedLine(line)
      @buffer = ''
    end

    if (size = @socket.bytes_available) > 0
      data = @socket.read_all
      @buffer += data.to_s.gsub("\r", '')
      emit receivedText(@buffer)
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
    os = Qt::TextStream.new(@socket)
    os << text << "\n"
    os.flush
  end
end

end
