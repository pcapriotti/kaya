require 'socket'

module ICS

# 
# A connection to an ICS server
# 
class Connection
  attr_accessor :debug

  def initialize(host, port, protocol)
    @protocol = protocol
    @create_socket = lambda do 
      puts "connecting to #{host}:#{port}"
      TCPSocket.new(host, port)
    end

    @state = :stopped
    @stop_flag = false
    @last_chunk = ''
    @ignore_pending = false
    @debug = false
  end

  def start
    @stop_flag = false
    @socket = @create_socket[]

    Thread.new do
      loop do
        break if @stop_flag
        data = @socket.recv(1024)
        break unless data
        read_chunk data
      end

      @state = :stopped
    end
  end

  def stop
    @stop_flag = true
  end

  def send(data)
    puts "> #{data}" if @debug
    @socket.print(data + "\n\r")
  end

  private

  def read_chunk(data)
    return if data.empty?
    chunks = data.split("\n\r", -1) # don't omit trailing empty fields

    i = if @ignore_pending
      1
    else
      chunks[0] = @last_chunk + chunks[0]      
      0
    end
    chunks[i...-1].each do |c| 
      line = c.chomp
      processed = @protocol.process line
      puts "< #{line}" if @debug
    end
    if not chunks.last.empty?
      @last_chunk = chunks.last
      @ignore_pending = @protocol.process_partial @last_chunk
    end
  end
end

end
