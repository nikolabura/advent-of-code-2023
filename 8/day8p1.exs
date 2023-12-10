require IEx

{:ok, contents} = File.read("input.txt")

[instructions | network] =
  contents
  |> String.split("\n", trim: true)

IO.inspect(instructions, label: "instructions")

network = network
  |> Enum.map(fn str ->
    [_, from, left, right] = Regex.run(~r/(...) = \((...), (...)\)/, str)
    {from, {left, right}}
  end)
  |> Map.new
  |> IO.inspect(label: "network")

String.graphemes(instructions)
  |> Stream.cycle()
  |> Enum.reduce_while({"AAA", 0}, fn instruction, {cur_node, count} ->
    from_here = network[cur_node]
    going = if instruction == "L", do: elem(from_here, 0), else: elem(from_here, 1)
    IO.puts("#{count}: From node #{cur_node} got instruction #{instruction}, looked up map #{inspect(from_here)}, going #{going}")
    {(if going == "ZZZ", do: :halt, else: :cont), {going, count + 1}}
  end)
  |> IO.inspect()

IEx.pry()
