# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

class Descriptor
  attr_reader :name, :opts, :children
  
  def initialize(name, opts = { })
    @name = name
    @opts = opts
    @children = []
  end
  
  def add_child(desc)
    @children << desc
  end
  
  def merge_child(desc)
    mp = @opts[:merge_points].first if @opts[:merge_points]
    if mp
      @children.insert(mp.position, desc)
      @opts[:merge_points].step!
    else
      add_child(desc)
    end
  end
  
  def first_valid_merge_point
    if @opts[:merge_points]
      @opts[:merge_points].first
    end
  end
  
  def to_sexp
    "(#{@name} #{@opts.inspect}#{@children.map{|c| ' ' + c.to_sexp}.join})"
  end
  
  def merge!(other, prefix = "")
    if name == other.name and
        opts[:name] == other.opts[:name]
      other.children.each do |child2|
        merged = false
        children.each do |child|
          if child.merge!(child2, prefix + "    ")
            merged = true
            break
          end
        end
        merge_child(child2.dup) unless merged
      end
      true
    elsif name == :group and other.opts[:group] == opts[:name]
      merge_child(other)
    else
      false
    end
  end
  
  class MergePoint
    attr_accessor :position, :count
    
    class List
      def initialize
        @mps = []
      end
      
      def first
        @mps.first.dup
      end
      
      def add(mp)
        @mps << mp
      end
      
      def step!
        raise "Stepping invalid merge point list" if @mps.empty?
        @mps.each do |mp|
          mp.position += 1
        end
        @mps.first.count -= 1
        clean!
      end
      
      private
      
      def clean!
        @mps.delete_if {|mp| not mp.valid? }
      end
    end
    
    def initialize(position, count = -1)
      @position = position
      @count = count
      raise "Creating invalid merge point" if @count == 0
    end
    
    def valid?
      @count != 0
    end
  end
  
  class Builder
    attr_reader :__desc__
    private :__desc__
    
    def initialize(desc)
      @__desc__ = desc
    end
    
    def method_missing(name, *args, &blk)
      opts = if args.empty?
        { }
      elsif args.size == 1
        if args.first.is_a? Hash
          args.first
        else
          { :name => args.first }
        end
      else
        args[-1].merge(:name => args.first)
      end
      child = Descriptor.new(name, opts)
      blk[self.class.new(child)] if block_given?
      __desc__.add_child(child)
    end
    
    def merge_point(count = -1)
      mp = MergePoint.new(@__desc__.children.size, count)
      @__desc__.opts[:merge_points] ||= MergePoint::List.new
      @__desc__.opts[:merge_points].add(mp)
    end
  end
end
