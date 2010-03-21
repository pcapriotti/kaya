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
    if @opts[:merge_point]
      @children.insert(@opts[:merge_point], desc)
      @opts[:merge_point] += 1
    else
      add_child(desc)
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
    else
      false
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
    
    def merge_point
      @__desc__.opts[:merge_point] = @__desc__.children.size
    end
  end
end
