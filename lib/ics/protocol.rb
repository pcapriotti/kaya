require 'observer_utils'
require 'ics/style12'

module ICS

class Protocol
  include Observable
  @@last_action = nil
  @@actions = []
  @@partial_actions = []
  GAME_TYPES = {
    :standard => :chess,
    :blitz => :chess,
    :lightning => :chess }

  def self.on(regex, type = :full, &blk)
    # ugly hack to work around the missing
    # instance_exec in ruby 1.8
    mname = "__action_#{regex.to_s}"
    if type == :partial
      @@partial_actions << [mname, regex]
    else type == :full
      @@actions << [mname, regex]
    end
    define_method mname, &blk
  end

  def initialize
    @games = {}
  end

  def process(line)
    processed = execute_action @@actions, line
    if not processed
      fire :text => line
    end
  end

  def process_partial(line)
    execute_action @@partial_actions, line
  end

  on %r{^Creating:\s+(\S+)\s+\((\S*)\)\s+(\S+)\s+\((\S*)\)
     \s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)}x do |match|
    @incoming_game = {
      :white => { 
        :name => match[1],
        :score => match[2].to_i },
      :black => {
        :name => match[3],
        :score => match[4].to_i },
      :rated => match[5],
      :type => match[6],
      :game => game_from_type(match[6]),
      :time => match[7].to_i,
      :increment => match[8].to_i }
    fire :creating_game => @incoming_game
  end

  on /^\{Game\s+(\d+)\s+\((\S+)\s+vs\.\s+(\S+)\)
      \s+(\S+.*)\}(.*)/x do |match|
    if match[4] =~ /^(Creating)|(Continuing)/
      if not @incoming_game
        # this should not happen
        info = match[4].split(/\s+/)
        if info.size >= 3
          @incoming_game = { 
            :white => { :name => match[2] },
            :black => { :name => match[3] },
            :rated => info[1],
            :type => info[2],
            # no time information available
            :time => 0, 
            :increment => 0 }
        end
      end
      if @incoming_game
        num = match[1].to_i
        @incoming_game[:number] = num
        @games[num] = @incoming_game
      end
    else
      if not @incoming_game
        num = match[1].to_i
        @games.delete(num)
        fire :end_game => {
          :message => match[4],
          :result => match[5].strip }
      end
    end
  end

  on /^login:/, :partial do
    fire :login_prompt
  end
  
  on /^password:/, :partial do
    fire :password_prompt
  end

  on /^Press return/ do
    fire :press_return_prompt
  end
  
  on(/^\S+% /, :partial) do |match|
    fire :prompt => match[0]
  end

  on(Style12::PATTERN) do |match|
    style12 = Style12.from_match(match, @games)
  end

  private
  
  def execute_action(actions, line)
    actions.each do |action, regex|
      m = regex.match(line)
      if m
        __send__ action, m
        return true
      end
    end

    return false
  end
  
  def game_from_type(type)
    Game.get(GAME_TYPES[type] || :dummy)
  end
end

class AuthModule
  include Observer
  
  def initialize(connection, username, password)
    @username = username
    @password = password
    @connection = connection
  end

  def on_login_prompt
    @connection.send(@username)
  end

  def on_password_prompt
    @connection.send(@password)
  end

  def on_press_return_prompt
    @connection.send('')
  end
end

class StartupModule
  include Observer
  
  def initialize(connection)
    @connection = connection
    @startup = false
  end

  def on_prompt
    if not @startup
      puts "starting up!"
      @connection.send("alias $ @");
      @connection.send("iset startpos 1");
      @connection.send("iset ms 1");
      @connection.send("iset lock 1");
      @connection.send("set interface Tagua-2.1 (http://www.tagua-project.org)");
      @connection.send("set style 12");
      @startup = true
    end
  end
end

end
