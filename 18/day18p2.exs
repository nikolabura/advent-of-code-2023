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

plan =
  contents
  |> String.split("\n", trim: true)

  |> Enum.map(fn x ->
    [_, _, x] = String.split(x, " ")
    dir = case String.at(x, -2) do
      "0" -> "R"
      "1" -> "D"
      "2" -> "L"
      "3" -> "U"
    end
    num = String.to_integer(String.slice(x, 2, 5), 16)
    {dir, num}
  end)

  # |> Enum.map(fn x -> [a, b, _] = String.split(x, " "); {a, String.to_integer(b)} end)

  # |> IO.inspect(label: "plan")


boundary = Enum.map(plan, fn {_, num} -> num end) |> Enum.sum() |> IO.inspect(label: "boundary")


{coords, _} = Enum.map_reduce(plan, {0, 0}, fn {dig_dir, dig_num}, cur_pos ->
  {cur_r, cur_c} = cur_pos
  next_point = case dig_dir do
    "U" -> {cur_r - dig_num, cur_c}
    "D" -> {cur_r + dig_num, cur_c}
    "L" -> {cur_r, cur_c - dig_num}
    "R" -> {cur_r, cur_c + dig_num}
  end
  {next_point, next_point}
end)
coords = [{0, 0}] ++ coords

IO.inspect(coords, label: "coordinates")

area = Enum.chunk_every(coords, 2, 1, :discard)
|> Enum.map(fn [{x1, y1}, {x2, y2}] ->
  s = (y1 + y2) * (x1 - x2)
  # IO.puts("(#{x1}, #{y1}) (#{x2}, #{y2}) #{s}")
  s
end)
|> Enum.sum()

area = Integer.floor_div(abs(area), 2)
IO.inspect(area, label: "area")

interior = area - Integer.floor_div(boundary, 2) + 1
IO.inspect(interior, label: "interior")

IO.inspect(boundary + interior, label: "final")


IEx.pry()
