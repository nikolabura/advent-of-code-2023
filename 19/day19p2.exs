require IEx

{:ok, contents} = File.read("input.txt")

[workflows, _] =
  contents
  |> String.split("\n\n", trim: true)

workflows = workflows
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [_, name, flow] = Regex.run(~r/(.*){(.*)}/, line)
    flow = String.split(flow, ",")
    flow = Enum.map(flow, fn item ->
      if String.contains?(item, ":") do
        String.split(item, ":") |> List.to_tuple()
      else
        item
      end
    end)
    {name, flow}
  end)
  |> Map.new()

defmodule Advent do
  def accepted_ranges(_vars, in_ranges, ["A"]) do
    IO.puts("Jump to accept.")
    in_ranges
  end

  def accepted_ranges(_vars, _in_ranges, ["R"]) do
    IO.puts("Jump to reject.")
    []
  end

  def accepted_ranges(vars, in_ranges, [jump_workflow]) when is_bitstring(jump_workflow) do
    IO.puts("Jump to #{jump_workflow}.")
    accepted_ranges(vars, in_ranges, vars.workflows[jump_workflow])
  end

  def accepted_ranges(vars, in_ranges, [{condition, jump_target} | next_rules]) do
    IO.inspect({condition, jump_target})

    [_, var, op, right] = Regex.run(~r/(.)(.)(\d+)/, condition)
    left = String.to_atom(var)
    op = if op == "<", do: &Kernel.</2, else: &Kernel.>/2
    right = String.to_integer(right)

    # {jumps, dontjumps} = Enum.split_with(in_ranges[left], fn l -> op.(l, right) end)
    # jumps = MapSet.new(jumps)
    # dontjumps = MapSet.new(dontjumps)

    # jumps_accepted     = accepted_ranges(vars, Map.put(in_ranges, left,     jumps), [jump_target])
    # dontjumps_accepted = accepted_ranges(vars, Map.put(in_ranges, left, dontjumps), next_rules)

    Enum.map(in_ranges, fn consider_range ->
      IO.inspect(consider_range)
      {jmps, njmps} = Enum.split_with(consider_range[left], fn l -> op.(l, right) end)
       jmps = MapSet.new( jmps)
      njmps = MapSet.new(njmps)

      # IO.inspect(jmps)
      # IO.inspect(njmps)

      jmps_accept = if MapSet.size(jmps) == 0, do: [],
        else: accepted_ranges(vars, [Map.put(consider_range, left, jmps)], [jump_target])

      njmps_accept = if MapSet.size(njmps) == 0, do: [],
        else: accepted_ranges(vars, [Map.put(consider_range, left, njmps)], next_rules)

      jmps_accept ++ njmps_accept
    end) |> List.flatten()
  end
end

vars = %{
  workflows: workflows
}

initial_ranges = [%{
  x: MapSet.new(1..4000),
  m: MapSet.new(1..4000),
  a: MapSet.new(1..4000),
  s: MapSet.new(1..4000)
}]

# initial_ranges = [%{
#   x: MapSet.new([787]),
#   m: MapSet.new([2655]),
#   a: MapSet.new([1222]),
#   s: MapSet.new(1..4000)
# }]

out_ranges = Advent.accepted_ranges(vars, initial_ranges, workflows["in"])
  |> IO.inspect(label: "out ranges")
#   |> Enum.map(fn map -> Enum.map(map, fn {k, v} -> {k, MapSet.to_list(v)} end) end)
#   |> IO.inspect()

Enum.map(out_ranges, fn range ->
  Map.values(range) |> Enum.map(fn x -> MapSet.size(x) end) |> List.to_tuple() |> Tuple.product()
end) |> Enum.sum |> IO.inspect()

# a_out = Enum.map(out_ranges, fn x -> Keyword.get(x, :a) end) |> List.flatten |> Enum.uniq |> Enum.count |> IO.inspect()
# a_out = Enum.map(out_ranges, fn x -> Keyword.get(x, :m) end) |> List.flatten |> Enum.uniq |> Enum.count |> IO.inspect()
# a_out = Enum.map(out_ranges, fn x -> Keyword.get(x, :a) end) |> List.flatten |> Enum.uniq |> Enum.count |> IO.inspect()
# a_out = Enum.map(out_ranges, fn x -> Keyword.get(x, :s) end) |> List.flatten |> Enum.uniq |> Enum.count |> IO.inspect()

IEx.pry()
