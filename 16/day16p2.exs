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
    new_row = Map.new(String.graphemes(row) |> Enum.with_index(), fn {char, index} -> {index, char} end)
    {index, new_row}
  end)
  # |> Advent.print2d()

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])
IO.puts("")

add = fn {r1, c1}, {r2, c2} ->
  {r1 + r2, c1 + c2}
end

north = {-1,  0}
south = { 1,  0}
east  = { 0,  1}
west  = { 0, -1}

top    = Enum.map(0..num_cols-1, fn col -> start = {0,            col}; {add.(start, north), start} end)
bottom = Enum.map(0..num_cols-1, fn col -> start = {num_rows - 1, col}; {add.(start, south), start} end)
left   = Enum.map(0..num_rows-1, fn row -> start = {row,            0}; {add.(start, west),  start} end)
right  = Enum.map(0..num_rows-1, fn row -> start = {row, num_cols - 1}; {add.(start, east),  start} end)
start_tuples = List.flatten([top, bottom, left, right])

:ets.new(:table, [:named_table, :public])
:ets.insert(:table, {:counter, 0})

{:ok, {answer, ener}} = Task.async_stream(start_tuples, fn start_tuple ->
  {_, first_pos} = start_tuple
  {_, ener, _} = Enum.reduce_while(0..9999, {
      [
        start_tuple
      ],
      MapSet.new([first_pos]),
      0
    },
      fn _, {beamfronts, energized, repeat_count} ->
    # IO.inspect(beamfronts, label: "original beamfronts")
    new_beamfronts = Enum.map(beamfronts, fn {came_from, currently_on} ->
      {came_r, came_c} = came_from
      {curr_r, curr_c} = currently_on
      was_going = {curr_r - came_r, curr_c - came_c}
      continue_goings = case grid[curr_r][curr_c] do
        "." -> was_going

        "/" -> case was_going do
          ^north -> east
          ^south -> west
          ^west  -> south
          ^east  -> north
        end

        "\\" -> case was_going do
          ^north -> west
          ^south -> east
          ^west  -> north
          ^east  -> south
        end

        "|" -> case was_going do
          ^north -> north
          ^south -> south
          ^west  -> [north, south]
          ^east  -> [north, south]
        end

        "-" -> case was_going do
          ^north -> [east, west]
          ^south -> [east, west]
          ^west  -> west
          ^east  -> east
        end
      end
      continue_goings = List.flatten([continue_goings])
      new_positions =
        Enum.map(continue_goings, fn continue_going ->
          add.(currently_on, continue_going)
        end)
        |> Enum.reject(fn {new_pos_r, new_pos_c} ->
            new_pos_r < 0
          or new_pos_c < 0
          or new_pos_r >= num_rows
          or new_pos_c >= num_cols
        end)
      Enum.map(new_positions, fn new_pos ->
        {currently_on, new_pos}
      end) #|> IO.inspect(label: "new beamfronts")
    end) |> List.flatten()

    new_beamfronts = Enum.dedup(new_beamfronts)

    cur_ons = Enum.map(new_beamfronts, fn {_, cur_on} -> cur_on end)
    # Advent.print2d(grid, cur_ons)
    new_energized = MapSet.new(cur_ons)
    new_energized = MapSet.union(energized, new_energized)
    {
      if(repeat_count > 10, do: :halt, else: :cont),
      {
        new_beamfronts,
        new_energized,
        if(new_energized == energized, do: repeat_count + 1, else: 0)
      }
    }
  end)

  ener = MapSet.to_list(ener)
  # IO.puts("")
  # if length(ener) == 52 do
  #   Advent.print2d(grid, ener)
  # end
  [counter: count] = :ets.lookup(:table, :counter)
  :ets.update_counter(:table, :counter, 1)
  IO.puts("#{inspect(start_tuple)}   energized: #{length(ener)}   done: #{Float.round((count / length(start_tuples)) * 100, 2)}%")
  {length(ener), ener}
end, timeout: :infinity)
|> Enum.to_list()
|> Enum.max_by(fn {:ok, {x, _}} -> x end)

Advent.print2d(grid, ener)
IO.inspect(answer, label: "max")

IEx.pry()
