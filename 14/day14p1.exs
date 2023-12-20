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

grid = Enum.reduce_while(0..10000, grid, fn _, grid ->
  IO.puts("")
  pre_grid = grid
  grid = Enum.reduce(1..num_rows-1, grid, fn row, grid ->
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
  end) |> Advent.print2d()
  {(if pre_grid != grid, do: :cont, else: :halt), grid}
end)

Enum.map(grid, fn {row_id, row} ->
  row_val = num_rows - row_id
  num_rocks = Map.values(row) |> Enum.count(fn x -> x == "O" end)
  row_val * num_rocks
end) |> Enum.sum() |> IO.inspect()

IEx.pry()
