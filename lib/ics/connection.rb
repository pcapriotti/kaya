require 'socket'

module ICS

# 
# A connection to an ICS server
# 
class Connection
  def initialize(host, port, username, password)
    @create_socket = lambda do 
      puts "connecting to #{host}:#{port}"
      TCPSocket.new(host, port)
    end
    @state = :stopped

    @username = username
    @password = password
    @stop_flag = false
    @last_chunk = ''
    @ignore_pending = false
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
    puts "> #{data}"
    @socket.print(data + "\n\r")
  end

  private

  def read_chunk(data)
    return if data.empty?
    chunks = data.split("\n\r")

    i = if @ignore_pending
      1
    else
      chunks[0] = @last_chunk + chunks[0]      
      0
    end
    chunks[i...-1].each {|c| process c.chomp }
    @last_chunk = chunks.last
    @ignore_pending = process @last_chunk
  end

  def process(line)
    case line
    when /^login:\s*/
      send @username
    when /^password:\s*/
      send @password
    when /^Press return/
      send ""
    when /^[^\s]+% /
      # prompt
      @last_chunk = ''
      return false
    else
      return false
    end

    puts "< #{line}"
    return true
  end
end

end
