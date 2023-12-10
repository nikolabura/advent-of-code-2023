require IEx

{:ok, contents} = File.read("input.txt")

input =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn s ->
    s
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
  end)
  |> IO.inspect(label: "input")
  |> Enum.map(fn history ->
    IO.inspect(history, label: "history")
    Stream.unfold(history, fn array ->
      if Enum.all?(array, fn x -> x == 0 end) do
        nil
      else
        {_, differences} = Enum.reduce(array, {nil, []}, fn x, {last_val, differences} ->
          if last_val == nil do
            {x, []}
          else
            {x, differences ++ [x - last_val]}
          end
        end)
        IO.inspect(differences, label: "differences", charlists: :as_lists)
        {array, differences}
      end
    end) |> Enum.to_list()
  end)
  |> IO.inspect()
  |> Enum.map(fn differences_array ->
    rev = Enum.reverse(differences_array)
    Enum.reduce(rev, 0, fn chain, prev_last ->
      IO.inspect(chain, label: "chain")
      IO.inspect(prev_last, label: "prev_last")
      List.last(chain) + prev_last
    end) |> IO.inspect()
  end)
  |> Enum.sum()

IO.inspect(input)

IEx.pry()
