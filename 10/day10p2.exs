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

{row_s, _} = Enum.find(grid, fn row -> String.contains?(inspect(row, limit: :infinity), "S") end)
{col_s, _} = Enum.find(grid[row_s], fn {_, char} -> char == "S" end)
IO.puts("S is at #{row_s}, #{col_s}")
Advent.print2d(grid, {row_s, col_s})

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])

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
next_pos = List.first(next_poses)

IO.puts("\nLet's navigate towards #{inspect(next_pos)}.")
path = Stream.unfold({s_pos, next_pos, 0}, fn {last_pos, this_pos, counter} ->
  {last_pos_r, last_pos_c} = last_pos
  {this_pos_r, this_pos_c} = this_pos
  # Advent.print2d(grid, this_pos)
  # IO.puts("")
  last_travel = {-1 * (this_pos_r - last_pos_r), -1 * (this_pos_c - last_pos_c)}
  this_symbol = grid[this_pos_r][this_pos_c]
  if this_symbol == "S" do
    nil
  else
    [{next_offset_r, next_offset_c}] = Tuple.to_list(symbols[this_symbol]) |> Enum.reject(fn dir -> dir == last_travel end)
    next_pos = {this_pos_r + next_offset_r, this_pos_c + next_offset_c}
    # IO.inspect(next_pos)
    # next_symbol = grid[elem(next_pos, 0)][elem(next_pos, 1)]
    {
      this_pos,
      {this_pos, next_pos, counter + 1}
    }
  end
end) |> Enum.to_list()
path = path ++ [s_pos]
IO.inspect(path)

path_vis = Map.new(for r <- 0..num_rows do
  col = for c <- 0..num_cols do
    {c, Enum.member?(path, {r, c})}
  end
  {r, Map.new(col)}
end)
Advent.print2d(path_vis)

IO.puts("\n===\n")

trace_insides = fn inside_is_to_the ->
  IO.puts("\nTracing assuming inside is to the #{inside_is_to_the}...")

  painted = Enum.reduce(path, {s_pos, grid}, fn this_pos, {last_pos, painted_grid} ->
    # IO.inspect(this_pos)
    {last_pos_r, last_pos_c} = last_pos
    {this_pos_r, this_pos_c} = this_pos
    this_symbol = grid[this_pos_r][this_pos_c]
    came_from = {-1 * (this_pos_r - last_pos_r), -1 * (this_pos_c - last_pos_c)}

    paint_to_the = case inside_is_to_the do
      :left -> case {this_symbol, came_from} do
        {"S", _} -> []

        {"|", ^north} -> [east]
        {"|", ^south} -> [west]

        {"-", ^east} -> [south]
        {"-", ^west} -> [north]

        {"L", ^north} -> []
        {"L", ^east} -> [south, west]

        {"J", ^north} -> [south, east]
        {"J", ^west} -> []

        {"7", ^south} -> []
        {"7", ^west} -> [north, east]

        {"F", ^south} -> [north, west]
        {"F", ^east} -> []
      end

      :right -> case {this_symbol, came_from} do
        {"S", _} -> []

        {"|", ^north} -> [west]
        {"|", ^south} -> [east]

        {"-", ^east} -> [north]
        {"-", ^west} -> [south]

        {"L", ^north} -> [south, west]
        {"L", ^east} -> []

        {"J", ^north} -> []
        {"J", ^west} -> [south, east]

        {"7", ^south} -> [north, east]
        {"7", ^west} -> []

        {"F", ^south} -> []
        {"F", ^east} -> [north, west]
      end
    end

    painted_grid = if paint_to_the == [] do
      painted_grid
    else
      Enum.reduce(paint_to_the, painted_grid, fn {paint_r, paint_c}, painted_grid ->
        paint_r = this_pos_r + paint_r
        paint_c = this_pos_c + paint_c
        can_paint_here =
          not Enum.member?(path, {paint_r, paint_c})
          and paint_r >= 0 and paint_r < num_rows
          and paint_c >= 0 and paint_c < num_cols
        painted_grid = if not can_paint_here do
          painted_grid
        else
          put_in(painted_grid[paint_r][paint_c], "I")
        end
      end)
    end
    {this_pos, painted_grid}
  end) |> elem(1)

  # Advent.print2d(painted, path)
  all_coords = for r <- 0..num_rows-1 do for c <- 0..num_cols-1 do {r, c} end end |> List.flatten()

  # IO.puts("Expand")
  painted = Enum.reduce(0..3, painted, fn _, painted ->
    paint_coords = Enum.reduce(all_coords, [], fn {coord_r, coord_c}, paint_coords ->
      if painted[coord_r][coord_c] == "I" do
        paint_coords ++
          Enum.map([north, south, east, west], fn {paint_r, paint_c} ->
            paint_r = coord_r + paint_r
            paint_c = coord_c + paint_c
            can_paint_here =
              not Enum.member?(path, {paint_r, paint_c})
              and painted[paint_r][paint_c] != "I"
              and paint_r >= 0 and paint_r < num_rows
              and paint_c >= 0 and paint_c < num_cols
            if can_paint_here, do: {paint_r, paint_c}, else: nil
          end) |> Enum.reject(&is_nil/1)
      else
        paint_coords
      end
    end) |> Enum.uniq()
    painted = Enum.reduce(paint_coords, painted, fn {coord_r, coord_c}, painted ->
      put_in(painted[coord_r][coord_c], "I")
    end)
    painted
  end)
  Advent.print2d(painted, path)

  Enum.map(painted, fn {_, row} ->
    Enum.map(row, fn {_, char} -> if char == "I", do: 1, else: 0 end)
  end) |> List.flatten |> Enum.sum |> IO.inspect(label: "inside count")
end

trace_insides.(:left)
trace_insides.(:right)

IEx.pry()
