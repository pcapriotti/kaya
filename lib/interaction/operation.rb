# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

module Operation
  attr_reader :undo_op
  
  def undo
    undo_op.execute(:undoable => false) if undo_op
  end
end

# Add new moves at the end of a history
# 
class MoveOperation
  include Operation
  
  def initialize(history, *items)
    @history = history
    @items = items
  end
  
  def execute(opts = { })
    index = @history.add_items(opts[:extra] || { }, *@items)
    
    if opts.fetch(:undoable, true)
      @undo_op = TruncateOperation.new(@history, index)
    end
  end
end

# Truncate the history from the given index to
# the end
# 
class TruncateOperation
  include Operation
  
  def initialize(history, index)
    @history = history
    @index = index
  end
  
  def execute(opts = { })
    items = @history.remove_items_at(@index)
    if opts.fetch(:undoable, true)
      @undo_op = MoveOperation.new(@history, *items)
    end
  end
end

class CompositeOperation
  def initialize(*actions)
    @actions = actions
  end
  
  def undo
    @actions.reverse.each do |action|
      action.undo
    end
  end
  
  def execute(opts = { })
    @actions.each do |action|
      action.execute(opts)
    end
  end
end

module OperationInterface
  class OperationBuilder
    attr_reader :ops
    def initialize(history)
      @history = history
      @ops = []
    end

    def method_missing(m, *args)
      klass = eval(m.to_s.capitalize + "Operation")
      @ops << klass.new(@history, *args)
    end
  end
  
  def operation(opts = { })
    builder = OperationBuilder.new(self)
    yield builder
    ops = builder.ops
    op = case ops.size
    when 0
      nil
    when 1
      ops.first
    else
      CompositeOperation.new(*ops)
    end
    operations << op if opts.fetch(:save, true)
    op
  end
end