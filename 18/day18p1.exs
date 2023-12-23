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
  |> Enum.map(fn x -> [a, b, _] = String.split(x, " "); {a, String.to_integer(b)} end)
  # |> IO.inspect()

{_, filled_spots} = Enum.reduce(plan, {{0, 0}, []}, fn {dig_dir, dig_num}, {cur_pos, filled_spots} ->
  {cur_r, cur_c} = cur_pos
  new_filled = case dig_dir do
    "U" -> Enum.map(cur_r .. cur_r - dig_num, fn r -> {r, cur_c} end)
    "D" -> Enum.map(cur_r .. cur_r + dig_num, fn r -> {r, cur_c} end)
    "L" -> Enum.map(cur_c .. cur_c - dig_num, fn c -> {cur_r, c} end)
    "R" -> Enum.map(cur_c .. cur_c + dig_num, fn c -> {cur_r, c} end)
  end
  {Enum.at(new_filled, -1), new_filled ++ filled_spots}
end)

min_r = Enum.min(Enum.map(filled_spots, &(elem(&1, 0))))
min_c = Enum.min(Enum.map(filled_spots, &(elem(&1, 1))))
filled_spots = Enum.map(filled_spots, fn {r, c} -> {r - min_r, c - min_c} end)
filled_spots = Enum.dedup(filled_spots)

max_r = Enum.max(Enum.map(filled_spots, &(elem(&1, 0)))) #+ 2
max_c = Enum.max(Enum.map(filled_spots, &(elem(&1, 1)))) #+ 5

filled_grid = Map.new(0..max_r, fn r ->
  {r, Map.new(0..max_c, fn c -> {c, if({r, c} in filled_spots, do: "#", else: ".")} end)}
end) #|> Advent.print2d()

walls = MapSet.new(filled_spots)
start_point = {Integer.floor_div(max_r, 2), Integer.floor_div(max_c, 2)}
fanout_spots = MapSet.new([start_point])
{_, flooded} = Enum.reduce(0..max_c, {fanout_spots, MapSet.new()}, fn _, {new_spots, already_flooded} ->
  already_flooded = MapSet.union(new_spots, already_flooded)
  candidates = MapSet.new(Enum.map(new_spots, fn {r, c} -> [
    {r + 1, c}, {r - 1, c}, {r, c + 1}, {r, c - 1}
  ] end) |> List.flatten())
  next_new_spots = MapSet.difference(MapSet.difference(candidates, already_flooded), walls)
  # IO.inspect(next_new_spots)
  # Advent.print2d(filled_grid, MapSet.to_list(next_new_spots))
  {next_new_spots, already_flooded}
end)

spots = MapSet.union(walls, flooded) |> MapSet.to_list()
# Advent.print2d(filled_grid, spots)
IO.inspect(length(spots), label: "count")

IEx.pry()
