require IEx

{:ok, contents} = File.read("input")
contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn s -> Regex.replace(~r/[[:alpha:]]/, s, "") |> String.graphemes() end)
  |> Enum.map(fn arr -> String.to_integer(Enum.at(arr, 0) <> Enum.at(arr, -1)) end)
  |> IO.inspect(limit: :infinity)
  |> Enum.sum
  |> IO.inspect
