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
            IO.write(red() <> bright() <> inspect(char) <> reset())

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

  def lowest_cost_from(vars, position, came_from, straights_remaining, budget_remaining) do
    {curr_r, curr_c} = position
    {last_r, last_c} = came_from
    last_travel_r = curr_r - last_r
    last_travel_c = curr_c - last_c
    last_travel = {last_travel_r, last_travel_c}
    # IO.puts("#{String.duplicate(" ", vars.iters)}Checking #{inspect(position)} with #{straights_remaining} straights and #{budget_remaining} budget left.")
    if budget_remaining <= 0 do
      999999
    else
      cachekey = {position, came_from, straights_remaining, budget_remaining}
      case :ets.lookup(:cache, cachekey) do
        [{_, val}] ->
          # IO.inspect(cachekey, label: "cache hit")
          val

        [] ->
          cost_here = vars.grid[curr_r][curr_c]
          lowest_cost_onwards = if curr_r == vars.num_rows - 1 and curr_c == vars.num_cols - 1 do
            # IO.inspect("reached!")
            # Advent.print2d(vars.grid, vars.path)
            :ets.insert(:completions, {budget_remaining, [position] ++ vars.path})
            0
          else
            movement_options =
              [{0, 1}, {0, -1}, {-1, 0}, {1, 0}]
              |> Enum.reject(fn {r, c} -> r == -1 * last_travel_r and c == -1 * last_travel_c end) # can't go backwards
              |> Enum.map(fn o -> {o, o == last_travel} end) # mark with {, true} the one that continues straight

            movement_options =
              if straights_remaining == 0 do
                Enum.reject(movement_options, fn {_, str} -> str end) # can't continue straight
              else
                movement_options
              end

            next_tile_options = Enum.map(movement_options, fn {{r, c}, str} -> {{curr_r + r, curr_c + c}, str} end)
            next_tile_options = Enum.reject(next_tile_options, fn {{r, c}, _} ->
              r < 0 or c < 0 or r >= vars.num_rows or c >= vars.num_cols
            end)

            onwards_costs = Enum.map(next_tile_options, fn {next, is_straight} ->
              lowest_cost_from(
                %{vars | iters: vars.iters + 1, path: [position] ++ vars.path},
                next,
                position,
                if(is_straight, do: straights_remaining - 1, else: 2),
                budget_remaining - cost_here
              )
            end)

            Enum.min(onwards_costs, &<=/2, fn -> 999999 end)
          end

          out = cost_here + lowest_cost_onwards
          :ets.insert(:cache, {cachekey, out})
          out
      end
    end
  end
end

{:ok, contents} = File.read("input.txt")

grid =
  contents
  |> String.split("\n", trim: true)
  |> Enum.with_index()
  |> Map.new(fn {row, index} ->
    new_row = Map.new(String.graphemes(row) |> Enum.map(&String.to_integer/1) |> Enum.with_index(),
      fn {char, index} -> {index, char} end)
    {index, new_row}
  end)
  # |> Advent.print2d()

num_rows = Enum.count(grid)
num_cols = Enum.count(grid[0])
IO.inspect(num_rows, label: "rows")
IO.puts("")

:ets.new(:completions, [:named_table])
:ets.new(:cache, [:named_table])

naive_path =
  Enum.map(0..num_rows-1, fn row -> {row, row} end) ++
  Enum.map(0..num_rows-2, fn row -> {row + 1, row} end)
naive_cost = Enum.map(naive_path, fn {r, c} -> grid[r][c] end) |> Enum.sum()
Advent.print2d(grid, naive_path)
IO.inspect(naive_cost, label: "easy traversal cost")

vars = %{
  path: [],
  iters: 0,
  grid: grid,
  num_rows: num_rows,
  num_cols: num_cols
}

lowest_cost = Advent.lowest_cost_from(
  vars, {0, 1}, {0, 0}, 2, naive_cost
) |> IO.inspect(label: "lowest cost")

finalpaths = :ets.match(:completions, :"$1")
[{_, finalpath}] = Enum.max_by(finalpaths, fn [{c, _}] -> c end)
Advent.print2d(grid, finalpath)

IEx.pry()
