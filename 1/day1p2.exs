require IEx

digits = [
  {"one", 1},
  {"two", 2},
  {"three", 3},
  {"four", 4},
  {"five", 5},
  {"six", 6},
  {"seven", 7},
  {"eight", 8},
  {"nine", 9},
  {"1", 1},
  {"2", 2},
  {"3", 3},
  {"4", 4},
  {"5", 5},
  {"6", 6},
  {"7", 7},
  {"8", 8},
  {"9", 9},
]

{:ok, contents} = File.read("input")
contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn s ->
    IO.inspect(s)
    matches =
      Enum.map(digits, fn {matcher, val} ->
        reg = Regex.compile!(matcher)
          |> Regex.run(s, return: :index)
        case reg do
          [{pos, _}] -> {pos, val}
          nil -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
      #|> IO.inspect()
    {{_, first}, {_, last}} = Enum.min_max_by(matches, fn {pos, val} -> pos end) #|> IO.inspect()
    number = first * 10 + last
    IO.puts(number)
    number
  end)
  |> IO.inspect(limit: :infinity)
  |> Enum.sum()
