require IEx

defmodule Advent do
  def print2d(mat) do
    for {_k, row} <- mat do
      for {_k, char} <- row do
        IO.write(char)
      end
      IO.puts("")
    end
    mat
  end
end

{:ok, contents} = File.read("input")

input =
  contents
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Map.new(fn {row, index} ->
    new_row = Map.new(String.graphemes(row) |> Enum.with_index(), fn {char, index} -> {index, char} end)
    {index, new_row}
  end)
  |> Advent.print2d()

IO.puts("")
size = Enum.max(Map.keys(input))

matrix_out =
  for {y, row} <- input do
    range_y = max(y - 1,0)..min(y + 1,size)
    row_out =
      for {x, char} <- row do
        range_x = max(x - 1,0)..min(x + 1,size)
        any_symbols_surrounding =
          for y <- range_y do
            for x <- range_x do
              not Regex.match?(~r/[\d\.]/, input[y][x])
            end
          end
        any_symbols_surrounding = List.flatten(any_symbols_surrounding)
        any_symbols_surrounding = Enum.any?(any_symbols_surrounding)
        {x, any_symbols_surrounding}
      end
    {y, Map.new(row_out)}
  end
tiles_touching = Map.new(matrix_out)

nums =
  for {row, y} <- contents |> String.split("\n", trim: true) |> Enum.with_index() do
    tiles_touching_this_row = tiles_touching[y]
    numeric_matches = Regex.scan(~r/\d+/, row, return: :index)
    for [{index, len}] <- numeric_matches do
      range = index .. index+len-1
      valid = range |> Enum.map(fn i -> tiles_touching_this_row[i] end) |> Enum.any?()
      if valid do
        String.slice(row, range) |> String.to_integer()
      else
        :nil
      end
    end |> Enum.reject(&is_nil/1)
  end

IO.inspect(List.flatten(nums) |> Enum.sum)

IEx.pry()
