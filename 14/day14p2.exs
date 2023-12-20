require IEx

import IO.ANSI

# copied from day 3
defmodule Advent do
  def print2d(mat, highlight \\ nil) do
    row_ids = Enum.sort(Map.keys(mat))
    for row_num <- row_ids do
      row = mat[row_num]
      char_ids = Enum.sort(Map.keys(row))
      for char_num <- char_ids do
        char = row[char_num]
        cond do
          highlight == {row_num, char_num} -> IO.write(blue() <> bright() <> char <> reset())
          is_list(highlight) and Enum.member?(highlight, {row_num, char_num}) ->
            IO.write(blue() <> char <> reset())

          char == "I" -> IO.write(red() <> char <> reset())

          is_boolean(char) ->
            IO.write(if char, do: "#", else: "-")
          is_binary(char) ->
            IO.write(char)
          true ->
            IO.write(inspect(char) |> String.trim())
        end
      end
      IO.puts("")
    end
    mat
  end

  def roll(grid, direction) do
    num_rows = Enum.count(grid)
    num_cols = Enum.count(grid[0])
    Enum.reduce_while(0..10000, grid, fn iteration, grid ->
      pre_grid = grid
      grid = case direction do
        :north -> tickNorth(grid, num_rows, num_cols)
        :south -> tickSouth(grid, num_rows, num_cols)
        :east  ->  tickEast(grid, num_rows, num_cols)
        :west  ->  tickWest(grid, num_rows, num_cols)
      end
      if iteration > 5000, do: raise "too much!"
      {(if pre_grid != grid, do: :cont, else: :halt), grid}
    end)
  end

  def tickNorth(grid, num_rows, num_cols) do
    Enum.reduce(1..num_rows-1, grid, fn row, grid ->
      Enum.reduce(0..num_cols-1, grid, fn col, grid ->
        this_tile = grid[row][col]
        tile_above = grid[row - 1][col]
        if this_tile != "O" do
          grid
        else
          if tile_above == "." do
            # move into the empty space!
            grid = put_in(grid[row - 1][col], "O")
            grid = put_in(grid[row][col], ".")
            grid
          else
            grid
          end
        end
      end)
    end)
  end

  def tickSouth(grid, num_rows, num_cols) do
    Enum.reduce(num_rows-2..0, grid, fn row, grid ->
      Enum.reduce(0..num_cols-1, grid, fn col, grid ->
        this_tile = grid[row][col]
        tile_below = grid[row + 1][col]
        if this_tile != "O" do
          grid
        else
          if tile_below == "." do
            # move into the empty space!
            grid = put_in(grid[row + 1][col], "O")
            grid = put_in(grid[row][col], ".")
            grid
          else
            grid
          end
        end
      end)
    end)
  end

  def tickEast(grid, num_rows, num_cols) do
    Enum.reduce(num_cols-2..0, grid, fn col, grid ->
      Enum.reduce(0..num_rows-1, grid, fn row, grid ->
        this_tile = grid[row][col]
        tile_right = grid[row][col + 1]
        if this_tile != "O" do
          grid
        else
          if tile_right == "." do
            # move into the empty space!
            grid = put_in(grid[row][col + 1], "O")
            grid = put_in(grid[row][col], ".")
            grid
          else
            grid
          end
        end
      end)
    end)
  end

  def tickWest(grid, num_rows, num_cols) do
    Enum.reduce(1..num_cols-1, grid, fn col, grid ->
      Enum.reduce(0..num_rows-1, grid, fn row, grid ->
        this_tile = grid[row][col]
        tile_left = grid[row][col - 1]
        if this_tile != "O" do
          grid
        else
          if tile_left == "." do
            # move into the empty space!
            grid = put_in(grid[row][col - 1], "O")
            grid = put_in(grid[row][col], ".")
            grid
          else
            grid
          end
        end
      end)
    end)
  end

end

{:ok, contents} = File.read("input.txt")

grid =
  contents
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Map.new(fn {row, index} ->
    new_row = Map.new(String.graphemes(row) |> Enum.with_index(), fn {char, index} -> {index, char} end)
    {index, new_row}
  end)
  |> Advent.print2d()

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])
IO.puts("")

{_, loads} = Enum.reduce(1..500, {grid, []}, fn i, {grid, results} ->
  grid = Enum.reduce([:north, :west, :south, :east], grid, fn dir, grid ->
    Advent.roll(grid, dir)
  end)
  IO.puts("\nAfter #{i} cycles:")
  # Advent.print2d(grid)
  load = Enum.map(grid, fn {row_id, row} ->
    row_val = num_rows - row_id
    num_rocks = Map.values(row) |> Enum.count(fn x -> x == "O" end)
    row_val * num_rocks
  end) |> Enum.sum() |> IO.inspect(label: "north load")
  {grid, results ++ [load]}
end)
og_loads = loads
loads = loads |> Enum.with_index |> Enum.drop(10)
IO.inspect(loads, charlists: :as_lists)#, limit: :infinity)
cycle = Enum.map(0..Integer.floor_div(length(loads)-1, 4), fn i ->
  {a, ind_a} = Enum.at(loads, i)
  {b, ind_b} = Enum.at(loads, i*2)
  if a == b and i > 0 do
    # IO.inspect(Enum.slice(loads, i, i), charlists: :as_lists)
    # IO.inspect(Enum.slice(loads, i*2, i), charlists: :as_lists)
    # IO.inspect(Enum.slice(loads, i*3, i), charlists: :as_lists)
    a1 = Enum.slice(loads, i, i)
    a2 = Enum.slice(loads, i*2, i)
    a3 = Enum.slice(loads, i*3, i)
    all_eq = Enum.zip(Enum.zip(a1, a2), a3)
      |> Enum.all?(fn {{{a1, _}, {a2, _}}, {a3, _}} -> a1 == a2 and a2 == a3 end)
    if all_eq do
      a1
    end
  end
end)
  |> Enum.reject(&is_nil/1)
  |> List.first()
  |> IO.inspect(label: "cycle")

[{_, cycle_start_index} | _] = cycle
cycle_length = length(cycle)

predict = fn pos ->
  cycle_pos = pos - cycle_start_index
  elem(Enum.at(cycle, rem(cycle_pos, cycle_length)), 0)
end

IO.inspect(predict.(50))
IO.inspect(Enum.at(loads, 50 - 10))
IO.inspect(predict.(51))
IO.inspect(Enum.at(loads, 51 - 10))

IO.inspect(predict.(1000000000 - 1), label: "final")

IEx.pry()
