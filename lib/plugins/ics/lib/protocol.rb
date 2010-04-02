# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'observer_utils'
require_bundle 'ics', 'style12'
require_bundle 'ics', 'icsapi'

module ICS

class Protocol
  include Observable
  @@last_action = nil
  @@actions = Hash.new {|h, k| h[k] = [] }
  @@partial_actions = Hash.new {|h, k| h[k] = [] }
  GAME_TYPES = {
    'standard' => :chess,
    'blitz' => :chess,
    'lightning' => :chess,
    'crazyhouse' => :crazyhouse }
    
  attr_reader :connection

  def self.on(regex, opts = { }, &blk)
    # ugly hack to work around the missing
    # instance_exec in ruby 1.8
    mname = "__action_#{regex.to_s}"
    state = opts.fetch(:state, :normal)

    if opts[:type] == :partial
      @@partial_actions[state] << [mname, regex]
    else
      @@actions[state] << [mname, regex]
    end
    define_method mname, &blk
  end

  def initialize(debug)
    @debug = debug
    @games = {}
    @last_partial_offset = 0
    
    @state = :normal
  end

  def link_to(connection)
    raise "protocol already linked" if @connection
    @connection = connection
    connection.on(:received_line) do |line|
      process line[@last_partial_offset..-1]
    end
    connection.on(:received_text) do |text|
      process_partial text[@last_partial_offset..-1]
    end
  end

  def process(line)
    processed = execute_action @@actions[@state], line
    if not processed
      fire :text => line
    end
    
    @last_partial_offset = 0
  end

  def process_partial(line)
    if execute_action @@partial_actions[@state], line
      @last_partial_offset += line.size
    else
      @last_partial_offset = 0
    end
  end

  # This is the first of two messages issued by the server when a new game
  # is starting. Many of the information contained here is repeated in the
  # second message, but some, like time information, is only present here
  on %r{^Creating:\s+(\S+)\s+\((\S*)\)\s+(\S+)\s+\((\S*)\)
     \s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)}x do |match|
    game = game_from_type(match[6])
    @incoming_game = {
      :white => { 
        :name => match[1],
        :score => match[2].to_i },
      :black => {
        :name => match[3],
        :score => match[4].to_i },
      :rated => match[5],
      :type => match[6],
      :game => game,
      :icsapi => ICSApi.new(game),
      :time => match[7].to_i,
      :increment => match[8].to_i }
  end
  
  # This is the second message of a game creation.
  # The game number is contained here.
  on /^\{Game\s+(\d+)\s+\((\S+)\s+vs\.\s+(\S+)\)
      \s+(\S+.*)\}(.*)/x do |match|
    if match[4] =~ /^(Creating)|(Continuing)/
      if not @incoming_game
        # if this happens, it means that the first message has
        # been somehow lost
        # continue anyway, gathering as much information as possible
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
        # now we know the game number, so we can save
        # all the game information in the @games hash
        num = match[1].to_i
        @incoming_game[:number] = num
        @games[num] = @incoming_game
        fire :creating_game => @incoming_game
        @incoming_game = nil
      end
    else
      if not @incoming_game
        num = match[1].to_i
        @games.delete(num)
        fire :end_game => {
          :game_number => num,
          :message => match[4],
          :result => match[5].strip }
      end
    end
  end
  
  on /^Game (\d+): (\S+) reverts to main line move (\d+)\.$/ do |match|
    fire :examination_revert => {
      :game_number => match[1].to_i,
      :index => match[3].to_i }
  end

  on /^You are no longer examining game (\d+)\.$/ do |match|
    fire :end_examination => match[1].to_i
  end

  on /^\a$/ do
    fire :beep
  end

  on /^login:/, :type => :partial do
    fire :login_prompt
  end
  
  on /^password:/, :type => :partial do
    fire :password_prompt
  end

  on /^Press return/ do
    fire :press_return_prompt
  end
  
  on(/^\S+% /, :type => :partial) do |match|
    fire :prompt => match[0]
  end

  on(Style12::PATTERN) do |match|
    style12 = Style12.from_match(match, @games)
    fire :style12 => style12
  end
  
  on(/^\s*Movelist for game (\d+):/) do |match|
    @movelist = { :number => match[1].to_i }
    @state = :movelist_header
  end
  
  on /^(\S+) (\S+) match, initial time:/, :state => :movelist_header do |match|
    if @movelist
      @movelist[:rated] = match[1]
      @movelist[:type] = match[2]
    end
  end
  
  on /^[- ]+$/, :state => :movelist_header do |match|
    @state = :movelist
  end
  
  on /^\S*$/, :state => :movelist do |match|
    @state = :normal
    fire :movelist => @movelist
    @movelist = nil
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
    Game.get(GAME_TYPES[type]) || Game.dummy
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
    @connection.send_text(@username)
  end

  def on_password_prompt
    @connection.send_text(@password)
  end

  def on_press_return_prompt
    @connection.send_text('')
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
      @connection.send_text("alias $ @");
      @connection.send_text("iset startpos 1");
      @connection.send_text("iset ms 1");
      @connection.send_text("iset lock 1");
      @connection.send_text("set interface Tagua-2.1 (http://www.tagua-project.org)");
      @connection.send_text("set style 12");
      @startup = true
    end
  end
end

end
