#!/usr/bin/env ruby

require_relative 'grid'

# input = '.'*81
input = ".....8........1..65.3...4...2....9.4....8...3.9.3...8...479......64...21......6.."
grid = Grid.new(input)
grid.solve
p grid