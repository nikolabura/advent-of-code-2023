require IEx

{:ok, contents} = File.read("input.txt")

input =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn card ->
    [_, winning, have] = Regex.run(~r/:([ \d]+)\|([ \d]+)/, card)
    winning = String.split(winning, " ", trim: true) |> MapSet.new
    have    = String.split(have,    " ", trim: true) |> MapSet.new
    intersect = MapSet.intersection(winning, have)
    count = Enum.count(intersect)
    if count == 0, do: 0, else: Integer.pow(2, count - 1)
  end)
  |> Enum.sum()

IO.inspect(input)

IEx.pry()
