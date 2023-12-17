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

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])

cols_expand = for col <- 0..num_cols-1 do
  this_col = for row <- 0..num_rows-1 do
    grid[row][col]
  end
  if Enum.all?(this_col, fn x -> x == "." end), do: col, else: []
end |> List.flatten()
IO.inspect(cols_expand, label: "expand cols")

rows_expand = for row <- 0..num_rows-1 do
  this_row = for col <- 0..num_cols-1 do
    grid[row][col]
  end
  if Enum.all?(this_row, fn x -> x == "." end), do: row, else: []
end |> List.flatten()
IO.inspect(rows_expand, label: "expand rows")

highlight_cols = Enum.map(cols_expand, fn col -> Enum.map(0..num_rows-1, fn x -> {x,col} end) end) |> List.flatten()
highlight_rows = Enum.map(rows_expand, fn row -> Enum.map(0..num_cols-1, fn x -> {row,x} end) end) |> List.flatten()
Advent.print2d(grid, highlight_rows ++ highlight_cols)

expanded_amt = 1000000

galaxies = for row <- 0..num_rows-1 do
  for col <- 0..num_cols-1 do
    if grid[row][col] == "#" do
      expanded_rows_behind = Enum.filter(rows_expand, fn exp -> exp < row end) |> length
      expanded_cols_behind = Enum.filter(cols_expand, fn exp -> exp < col end) |> length
      new_col = col - expanded_cols_behind + expanded_cols_behind * expanded_amt
      new_row = row - expanded_rows_behind + expanded_rows_behind * expanded_amt
      IO.puts("""
        Galaxy at #{row},#{col} has #{expanded_rows_behind} exp rows above it \
        and #{expanded_cols_behind} exp cols left of it. \
        New coords are #{new_row},#{new_col} \
        """)
      {new_row, new_col}
    else
      []
    end
  end
end |> List.flatten() |> Enum.with_index(fn e, i -> {i+1, e} end) |> Map.new()
IO.inspect(galaxies, label: "galaxies")
max_gal_id = Enum.max(Map.keys(galaxies))

gal_pairs = for i <- 1..max_gal_id-1 do
  for j <- i+1..max_gal_id do
    {i, j}
  end
end |> List.flatten()

IO.inspect(max_gal_id, label: "gal count")
IO.inspect(length(gal_pairs), label: "pair count")

manhattan = fn {x1, y1}, {x2, y2} ->
  abs(x1 - x2) + abs(y1 - y2)
end

IO.inspect(manhattan.(galaxies[7], galaxies[1]))
IO.inspect(manhattan.(galaxies[6], galaxies[3]))
IO.inspect(manhattan.(galaxies[9], galaxies[8]))

Enum.map(gal_pairs, fn {g1, g2} ->
  manhattan.(galaxies[g1], galaxies[g2])
end) |> Enum.sum |> IO.inspect(label: "final sum")

IEx.pry()
