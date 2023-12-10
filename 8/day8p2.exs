require IEx

{:ok, contents} = File.read("input.txt")

[instructions | network] =
  contents
  |> String.split("\n", trim: true)

IO.inspect(instructions, label: "instructions")
IO.inspect(String.length(instructions), label: "instructions count")

network = network
  |> Enum.map(fn str ->
    [_, from, left, right] = Regex.run(~r/(...) = \((...), (...)\)/, str)
    {from, {left, right}}
  end)
  |> Map.new
  |> IO.inspect(label: "network")

instruction_cycle =
  String.graphemes(instructions)
  |> Stream.cycle()

starting_nodes = Map.keys(network) |> Enum.filter(fn n -> String.ends_with?(n, "A") end) |> IO.inspect(label: "start nodes")

values = Enum.map(starting_nodes, fn start_node ->
  Enum.reduce_while(instruction_cycle, {start_node, 0}, fn instruction, {cur_node, count} ->
    from_here = network[cur_node]
    going = if instruction == "L", do: elem(from_here, 0), else: elem(from_here, 1)
    # IO.puts("#{count}: From node #{cur_node} got instruction #{instruction}, looked up map #{inspect(from_here)}, going #{going}")
    done = String.ends_with?(going, "Z")
    {
      (if done, do: :halt, else: :cont),
      {going, count + 1}
    }
  end)
  |> IO.inspect(label: "from #{start_node} to")
end)
  |> Enum.map(fn {_, n} -> n end)
  |> IO.inspect(label: "values")

max_value = Enum.max(values)

max_multiplier = Stream.cycle([1])
  |> Enum.reduce_while(1, fn _, acc ->
    acc = acc + 1
    largest_product = max_value * acc
    if rem(acc, 1000000) == 0 do
      IO.puts("#{acc} * #{max_value} = #{largest_product}")
    end
    done =
      Enum.map(values, fn val -> rem(largest_product, val) end)
      # |> IO.inspect(label: "rems")
      |> Enum.all?(fn x -> x == 0 end)
    {
      (if done, do: :halt, else: :cont),
      acc
    }
  end)

IO.inspect(max_multiplier * max_value, label: "answer")

IEx.pry()
