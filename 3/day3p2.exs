require IEx

defmodule Advent do
  def print2d(mat) do
    row_ids = Enum.sort(Map.keys(mat))
    for row_num <- row_ids do
      row = mat[row_num]
      char_ids = Enum.sort(Map.keys(row))
      for char_num <- char_ids do
        char = row[char_num]
        cond do
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
        any_gears_around =
          for y <- range_y do
            for x <- range_x do
              if Regex.match?(~r/[\*]/, input[y][x]) do
                {y, x}
              else
                nil
              end
            end
          end
        any_gears_around = List.flatten(any_gears_around)
        any_gears_around = Enum.reject(any_gears_around, &is_nil/1)
        {x, any_gears_around}
      end
    {y, Map.new(row_out)}
  end
gears_touching = Map.new(matrix_out)

gear_nums =
  for {row, y} <- contents |> String.split("\n", trim: true) |> Enum.with_index() do
    gears_touching_this_row = gears_touching[y]
    numeric_matches = Regex.scan(~r/\d+/, row, return: :index)
    for [{index, len}] <- numeric_matches do
      range = index .. index+len-1
      touches = range |> Enum.map(fn i -> gears_touching_this_row[i] end) |> List.flatten() |> Enum.uniq()
      if Enum.count(touches) > 0 do
        [gear] = touches
        number = String.slice(row, range) |> String.to_integer()
        {gear, number}
      end
    end |> Enum.reject(&is_nil/1)
  end |> List.flatten()
  |> Enum.group_by(fn {gear, _} -> gear end, fn {_, num} -> num end)
  |> Enum.filter(fn {gear, nums} -> Enum.count(nums) == 2 end)
  |> Enum.map(fn {gear, [n1, n2]} -> n1 * n2 end)
  |> Enum.sum()

IO.inspect(gear_nums)

IEx.pry()
