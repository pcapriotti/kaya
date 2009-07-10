# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'games/validator_base'
require_bundle 'shogi', 'type'

module Shogi
  class Validator < ValidatorBase
    def initialize(state)
      super
    end
    
    def [](move)
      move.validate do |m|
        validate(m)
      end
    end
    
    def validate(move, target = nil)
      return false unless move.dropped || @state.board.valid?(move.src)
      return false unless @state.board.valid? move.dst
      
      piece = move.dropped
      if piece
        return false unless piece.color == @state.turn
        return false unless @state.pool(piece.color).has_piece?(piece)
        return false if move.promote?
        return false if @state.board[move.dst]
        if piece.type == :pawn
          # pawns cannot be dropped on the last rank
          return false if 
            move.dst.y == @state.row(@state.board.size.y - 1, piece.color)
          # do not allow two pawns on the same column
          return false if (0..@state.board.size.y).
                          map{|y| Point.new(move.dst.x, y) }.
                          any?{|p| @state.board[p]. == piece }
        elsif piece.type == :horse
          # horses cannot be dropped on the last or last-but-one rank
          return false if 
            move.dst.y == @state.row(@state.board.size.y - 1, piece.color) ||
            move.dst.y == @state.row(@state.board.size.y - 2, piece.color)
        end
      else
        piece = @state.board[move.src]
        return false unless piece and piece.color == @state.turn
        return false unless check_pseudolegality(piece, target, move)
      end
      
      
      @state.try(move) do |tmp|
        validator = self.class.new(tmp)
        legal = validator.check_legality(piece, target, move)
        return false unless legal
      end
      
      true
    end
    
    def validator_method(type)
      m = super(type)
      m = super(:gold) unless respond_to?(m)
      m
    end
    
    def check_pseudolegality(piece, target, move)
      if move.promote?
        return false if piece.type == :king or piece.type == :gold
        return false unless 
          @state.in_promotion_zone?(move.src, piece.color) ||
          @state.in_promotion_zone?(move.dst, piece.color)
          
        return false if Promoted.promoted?(piece.type)
      else
        # check for cases when it is mandatory to promote
        case piece.type
        when :pawn, :lance
          return false if move.dst.y == @state.row(@state.board.size.y - 1, piece.color)
        when :horse
          return false if 
            move.dst.y == @state.row(@state.board.size.y - 1, piece.color) ||
            move.dst.y == @state.row(@state.board.size.y - 2, piece.color)
        end
      end
      super(piece, target, move)
    end
    
    def validate_pawn(piece, target, move)
      move.delta == @state.direction(piece.color)
    end
    
    def validate_lance(piece, target, move)
      move.delta.x == 0 and
      move.delta.y.unit == @state.direction(piece.color).y and
      @state.board.clear_path? move.range
    end
    
    def validate_horse(piece, target, move)
      move.delta.x.abs == 1 and
      move.delta.y == 2 * @state.direction(piece.color).y
    end
    
    def validate_silver(piece, target, move)
      dir = @state.direction(piece.color).y
      (move.delta.y == dir and move.delta.x.abs <= 1) or
      (move.delta.x.abs == 1 and move.delta.y == -dir)
    end
    
    def validate_gold(piece, target, move)
      dir = @state.direction(piece.color).y
      (move.delta.y == dir and move.delta.x.abs <= 1) or
      move.delta.x.abs + move.delta.y.abs == 1
    end
    
    def validate_king(piece, target, move)
      move.delta.x.abs <= 1 and
      move.delta.y.abs <= 1
    end
    
    def validate_bishop(piece, target, move)
      range = move.range
      range.diagonal? and
      @state.board.clear_path? range
    end
    
    def validate_rook(piece, target, move)
      range = move.range
      range.parallel? and
      @state.board.clear_path? range
    end
    
    def validate_promoted_rook(piece, target, move)
      validate_king(piece, target, move) ||
      validate_rook(piece, target, move)
    end
    
    def validate_promoted_bishop(piece, target, move)
      validate_king(piece, target, move) ||
      validate_bishop(piece, target, move)
    end
    
    def each_move(src, dst, target)
      piece = @state.board[src]
      if piece
        moves = [@state.move_factory.new(src, dst)]
        if @state.in_promotion_zone?(dst, piece.color)
          moves << @state.move_factory.new(src, dst, :promotion => true)
        end
        moves.each do |m|
          yield m if check_pseudolegality(piece, target, m)
        end
      end
    end
  end
end
