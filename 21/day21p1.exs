require IEx

import IO.ANSI

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
            IO.write(red() <> bright() <> char <> reset())

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
    new_row = Map.new(String.graphemes(row) |> Enum.with_index(),
      fn {char, index} -> {index, char} end)
    {index, new_row}
  end)
  |> Advent.print2d()

{start_row, {start_col, _}} = Enum.map(grid, fn {rnum, row} ->
  if r = Enum.find(row, fn {k, v} -> v == "S" end), do: {rnum, r}, else: nil end) |> Enum.find(&is_tuple/1)
IO.inspect({start_row, start_col}, label: "start")

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])

possibles = Enum.reduce(1..64, [{start_row, start_col}], fn iter, step_poses ->
  possibles = step_poses
    |> Enum.flat_map(fn {r, c} ->
      [{r + 1, c}, {r - 1, c}, {r, c + 1}, {r, c - 1}]
    end)
    |> Enum.uniq()
    |> Enum.filter(fn {r, c} ->
      r >= 0 and r < num_rows and c >= 0 and c < num_cols
        and grid[r][c] != "#"
    end)
  IO.puts(iter)
  # Advent.print2d(grid, possibles)
  possibles
end)
IO.inspect(length(possibles))

IEx.pry()
