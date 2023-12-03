require IEx

{:ok, contents} = File.read("input")
contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    notpossible =
      line
      |> String.split(~r/[\:\;]/)
      |> Enum.drop(1)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn x ->
        String.split(x, ",")
          |> Enum.map(fn colorcount ->
            [val, color] = String.split(colorcount, " ", trim: true)
            limit = case color do
              "red" -> 12
              "green" -> 13
              "blue" -> 14
            end
            String.to_integer(val) > limit
          end)
      end)
      |> List.flatten()
      |> Enum.any?()
    [_, gamenum] = Regex.run(~r/Game (\d+):/, line)
    if not notpossible do
      String.to_integer(gamenum)
    else
      0
    end
  end)
  |> Enum.sum()
  |> IO.inspect()
