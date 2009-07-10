# Copyright (c) 2009 Paolo Capriotti <p.capriotti@gmail.com>
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

require 'test/unit'
require 'games/all'
require 'interaction/history'
require 'helpers/validation_helper'

class TestPGN < Test::Unit::TestCase
  include ValidationHelper
  
  PGN1 = <<-END_OF_PGN
[Result "0-1"]

1.e4 e5 0-1
  END_OF_PGN
  PGN2 = <<-END_OF_PGN
[Event "Oktoberfest"]
[White "Doe, John"]
[Black "Smith, Bob"]
[Result "1-0"]

1.Nf3 1-0
  END_OF_PGN
  PGN3 = <<-END_OF_PGN
[Event "Blindfold"]
[Site "Hollywood (USA)"]
[Date "1954.??.??"]
[EventDate "?"]
[Round "?"]
[Result "0-1"]
[White "Heinz Steiner"]
[Black "Arthur Bisguier"]
[ECO "B70"]
[WhiteElo "?"]
[BlackElo "?"]
[PlyCount "124"]

1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 6.Bg5 Bg7 7.Qd2
Nc6 8.Nb3 h6 9.Bh4 g5 10.Bg3 Nh5 11.Be2 Nxg3 12.hxg3 a5 13.a4
Be6 14.f4 Bxb3 15.cxb3 Nd4 16.Bc4 Rc8 17.Rd1 Qb6 18.Qf2 Qc5
19.fxg5 Ne6 20.g6 Qxf2+ 21.Kxf2 Ng5 22.gxf7+ Nxf7 23.Ke2 Ng5
24.Ke3 Rc5 25.Rd5 Ne6 26.Rf1 Be5 27.g4 Rf8 28.Rf5 Rf6 29.Rd1
Rg6 30.Rh1 Kd7 31.Nd5 Nc7 32.Nb6+ Kc6 33.Nd5 Kd7 34.Rf7 Nxd5+
35.exd5 Bf6 36.Kf3 Ke8 37.Rh7 Bg7 38.Bd3 Kf7 39.Bxg6+ Kxg6
40.Rxg7+ Kxg7 41.Re1 Kf7 42.Ke4 Rc2 43.g3 Rxb2 44.Re3 e6
45.dxe6+ Kxe6 46.Kd4+ Kd7 47.Kc4 Kc6 48.Re6 Rc2+ 49.Kd3 Rg2
50.Re3 Kc5 51.Ke4 d5+ 52.Kf5 d4 53.Re5+ Kb4 54.Rb5+ Kc3
55.Rxa5 d3 56.Rc5+ Kd4 57.Rc7 d2 58.Rd7+ Ke3 59.g5 hxg5 60.g4
Rg1 61.Kxg5 d1=Q 62.Rxd1 Rxd1 0-1
  END_OF_PGN
  
  PGN4 = <<-END_OF_PGN
[Event "Cheliabinsk"]
[Site "Cheliabinsk"]
[Date "1962.??.??"]
[Round "?"]
[White "Anatoli Karpov"]
[Black "Tarinin"]
[Result "1-0"]

1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 d6 5.Bxc6+ bxc6 6.d4 f6
7.O-O Bg4 8.dxe5 fxe5 9.Qd3 Be7 10.c4 Nf6 11.h3 Bxf3
12.Qxf3 O-O 13.Nc3 Nd7 14.Qg4 Bf6 15.Be3 Qe8 16.Rad1 Rb8
17.b3 Rf7 18.Rd3 Nf8 19.Ne2 Qd7 20.Qxd7 Rxd7 21.Rfd1 Rbd8
22.Nc3 Kf7 23.g3 Ke6 24.Kg2 Kf7 25.f4 exf4 26.gxf4 Bxc3
27.Rxc3 c5 28.Kf3 g6 29.Bf2 Ne6 30.Rcd3 c6 31.Bh4 Nd4+
32.Rxd4 cxd4 33.Bxd8 Rxd8 34.Rxd4 Ke7 35.c5 d5 36.exd5
cxd5 37.Ra4 Ra8 38.Ke3 Kd7 39.Kd4 Kc6 40.Rb4 a5 41.Rb6+
Kc7 42.Kxd5 Rd8+ 43.Rd6 Rf8 44.Ra6 Rf5+ 45.Kc4 Rxf4+
46.Kb5 a4 47.Ra7+ Kb8 48.Rxh7 axb3 49.axb3 Rf6 50.c6 Rf3
51.b4 Rf4 52.Ka5 Rc4 53.b5 1-0
  END_OF_PGN
  
  def setup
    @game = Game.get(:chess)
    @state = @game.state.new
    @state.setup
    @history = History.new(@state)
    @pgn = @game.game_writer
  end
  
  def test_pgn_black_wins
    add_move 4, 6, 4, 4
    add_move 4, 1, 4, 3
    info = { :result => :black }

    assert_equal PGN1, @pgn.write(info, @history)
  end
  
  def test_pgn_white_wins
    add_move 6, 7, 5, 5
    info = { :result => :white,
             :event => 'Oktoberfest',
             :players => { :white => 'Doe, John',
                           :black => 'Smith, Bob' } }

    assert_equal PGN2, @pgn.write(info, @history)
  end
  
  def test_pgn_read_tags
    info = {}
    @pgn.read(PGN2, info)
    
    assert_equal "Oktoberfest", info[:event]
    assert_equal "Doe, John", info[:players][:white]
    assert_equal "Smith, Bob", info[:players][:black]
    assert_equal "1-0", info[:result]
  end
  
  def test_pgn_read_moves
    info = {}
    @history = @pgn.read(PGN3, info)
    
    assert_move 1,   4, 6, 4, 4
    assert_move 2,   2, 1, 2, 3
    assert_move 3,   6, 7, 5, 5
    assert_move 12,  5, 0, 6, 1
  end
  
  def test_pgn_read_write
#     info = {}
#     @history = @pgn.read(PGN4, info)
#     text = @pgn.write(info, @history)
#     assert_equal PGN4, text
    # TODO reenable when suffixes work
  end
  
  private
  
  def add_move(*args)
    move = unpack_move(*args)
    validate = @game.validator.new(@history.state)
    assert validate[move]
    state = @history.state.dup
    state.perform! move
    @history.add_move(state, move)
  end
  
  def assert_move(index, *args)
    move = unpack_move(*args)
    assert_equal move.src, @history[index].move.src
    assert_equal move.dst, @history[index].move.dst
  end
end
