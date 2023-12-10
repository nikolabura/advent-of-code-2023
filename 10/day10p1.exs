require IEx

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
          highlight == {row_num, char_num} -> IO.write("█")
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

{row_s, _} = Enum.find(grid, fn row -> String.contains?(inspect(row, limit: :infinity), "S") end)
{col_s, _} = Enum.find(grid[row_s], fn {_, char} -> char == "S" end)
IO.puts("S is at #{row_s}, #{col_s}")
Advent.print2d(grid, {row_s, col_s})

north = {-1,  0}
south = { 1,  0}
east  = { 0,  1}
west  = { 0, -1}

symbols = %{
  "|" => {north, south},
  "-" => {east, west},
  "L" => {north, east},
  "J" => {north, west},
  "7" => {south, west},
  "F" => {south, east}
}

next_poses =
  Enum.map([north, south, east, west], fn check_pos ->
    {r, c} = check_pos
    there = grid[row_s + r][col_s + c]
    my_pos = {-1 * r, -1 * c}
    connected = case symbols[there] do
      nil -> false
      {^my_pos, _} -> true
      {_, ^my_pos} -> true
      _ -> false
    end
    {check_pos, connected}
  end)
  |> Enum.filter(fn {_, good} -> good end)
  |> Enum.map(fn {{r, c}, _} -> {row_s + r, col_s + c} end)
  |> IO.inspect(label: "next positions")

s_pos = {row_s, col_s}
# next_poses = [List.first(next_poses)]

out = Enum.map(next_poses, fn next_pos ->
  IO.puts("\nLet's navigate towards #{inspect(next_pos)}.")
  out = Stream.unfold({s_pos, next_pos, 0}, fn {last_pos, this_pos, counter} ->
    {last_pos_r, last_pos_c} = last_pos
    {this_pos_r, this_pos_c} = this_pos
    # Advent.print2d(grid, this_pos)
    # IO.puts("")
    last_travel = {-1 * (this_pos_r - last_pos_r), -1 * (this_pos_c - last_pos_c)}
    this_symbol = grid[this_pos_r][this_pos_c]
    [{next_offset_r, next_offset_c}] = Tuple.to_list(symbols[this_symbol]) |> Enum.reject(fn dir -> dir == last_travel end)
    next_pos = {this_pos_r + next_offset_r, this_pos_c + next_offset_c}
    # IO.inspect(next_pos)
    next_symbol = grid[elem(next_pos, 0)][elem(next_pos, 1)]
    if next_symbol == "S" do
      nil
    else
      {
        {this_pos, counter},
        {this_pos, next_pos, counter + 1}
      }
    end
  end) |> Enum.to_list()
  IO.inspect(out)
end)
|> List.flatten()
|> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))
|> Enum.map(fn {k, v} -> {k, Enum.min(v)} end)
|> Enum.max_by(fn {_, v} -> v end)
|> IO.inspect(label: "most distant")

IO.inspect(elem(out, 1) + 1, label: "answer")

IEx.pry()
