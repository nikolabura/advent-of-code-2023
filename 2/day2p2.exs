require IEx

{:ok, contents} = File.read("input")
contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    IO.puts(line)
    line
      |> String.split(~r/[\:\;]/)
      |> Enum.drop(1)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn game ->
        String.split(game, ",")
          |> Enum.map(fn colorcount ->
              [val, color] = String.split(colorcount, " ", trim: true)
              {color, String.to_integer(val)}
            end)
      end)
      |> List.flatten()
      |> Enum.group_by(fn {color, val} -> color end, fn {color, val} -> val end)
      |> Enum.map(fn {color, vals} ->
        {color, Enum.max(vals)}
      end)
      |> IO.inspect()
      |> Enum.map(fn {color, max} -> max end)
      |> Enum.reduce(fn val, acc -> acc * val end)
      |> IO.inspect()
  end)
  |> Enum.sum()
  |> IO.inspect()
