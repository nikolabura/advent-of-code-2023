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

out =
  contents
  |> String.split("\n\n", trim: true)
  |> Enum.map(fn x -> String.split(x, "\n", trim: true) end)
  # |> Enum.take(1)
  |> Enum.map(fn pattern ->
    IO.puts("Pattern:")
    grid =
      pattern
      |> Enum.with_index()
      |> Map.new(fn {row, index} ->
        new_row = Map.new(String.graphemes(row) |> Enum.with_index(), fn {char, index} -> {index, char} end)
        {index, new_row}
      end)
      |> Advent.print2d()

    num_rows = Enum.count(grid)
    num_cols = Enum.count(grid[0])

    vert_mirrors = for i <- 0..num_cols-2 do
      # Advent.print2d(grid,[{0, i}, {0, i+1}])
      col_indices =
        0..num_cols
        |> Enum.map(fn j -> {i-j, i+1+j} end)
        |> Enum.reject(fn {a, b} -> a < 0 or b > num_cols - 1 end)
      is_mirror = for {col1, col2} <- col_indices do
        col1 = Enum.map(0..num_rows-1, fn row -> grid[row][col1] end)
        col2 = Enum.map(0..num_rows-1, fn row -> grid[row][col2] end)
        col1 == col2
      end |> Enum.all?()
      IO.puts("vertical mirror on #{i}|#{i+1}? #{is_mirror}")
      {i+1, is_mirror}
    end

    hori_mirrors = for i <- 0..num_rows-2 do
      # Advent.print2d(grid,[{i, 0}, {i+1, 0}])
      row_indices =
        0..num_rows
        |> Enum.map(fn j -> {i-j, i+1+j} end)
        |> Enum.reject(fn {a, b} -> a < 0 or b > num_rows - 1 end)
      is_mirror = for {row1, row2} <- row_indices do
        row1 = Enum.map(0..num_cols-1, fn col -> grid[row1][col] end)
        row2 = Enum.map(0..num_cols-1, fn col -> grid[row2][col] end)
        row1 == row2
      end |> Enum.all?()
      IO.puts("horizontal mirror on #{i}|#{i+1}? #{is_mirror}")
      {100*(i+1), is_mirror}
    end

    [{out, _}] = vert_mirrors ++ hori_mirrors
      |> Enum.reject(fn {_, x} -> x == false end)
    out
  end)
  |> IO.inspect()
  |> Enum.sum()
  |> IO.inspect(label: "Final")

IEx.pry()
