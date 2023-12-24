require IEx

{:ok, contents} = File.read("input.txt")

config = contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [left, right] = String.split(line, " -> ")
    right = String.split(right, ", ")
    cond do
      String.starts_with?(left, "%") ->
        {String.slice(left, 1, 99), {:flipflop, :off, right}}
      String.starts_with?(left, "&") ->
        {String.slice(left, 1, 99), {:conj, %{}, right}}
      true ->
        {left, {:normal, nil, right}}
    end
  end)
  |> Map.new()

conjs = Enum.flat_map(config, fn {name, tup} -> if elem(tup, 0) == :conj, do: [name], else: [] end) |> MapSet.new()

to_conjs = Enum.flat_map(config, fn {name, {_, _, dests}} ->
  MapSet.intersection(MapSet.new(dests), conjs) |> Enum.map(fn dest -> {name, dest} end)
end)

config = Enum.reduce(to_conjs, config, fn {from, to}, config ->
  {:conj, conjstate, arr} = config[to]
  conjstate = Map.put(conjstate, from, :lo)
  Map.put(config, to, {:conj, conjstate, arr})
end) |> IO.inspect(label: "configuration")

:ets.new(:pulsecount, [:named_table, :public])
:ets.insert(:pulsecount, {:hi, 0})
:ets.insert(:pulsecount, {:lo, 0})

Enum.reduce(1..1000, config, fn i, config ->
  IO.puts("\n#{i}th ITERATION")
  Enum.reduce_while(Stream.cycle([0]), {config, [{"button", :lo, "broadcaster"}]}, fn _, {config, [next | queue]} ->
    {from, strength, to} = next
    IO.puts("#{from} -#{strength}-> #{to}")
    :ets.update_counter(:pulsecount, strength, 1)

    target = config[to]

    {config, queue} = case target do
      {:normal, _, outbounds} -> {config, queue ++ Enum.map(outbounds, fn o -> {to, strength, o} end)}

      {:flipflop, state, outbounds} ->
        if strength == :hi do
          # nothing happens
          {config, queue}
        else
          # flip it!
          new_state = if state == :on, do: :off, else: :on
          out_strength = if new_state == :on, do: :hi, else: :lo
          new_config = Map.put(config, to, {:flipflop, new_state, outbounds})
          {new_config, queue ++ Enum.map(outbounds, fn o -> {to, out_strength, o} end)}
        end

      {:conj, state, outbounds} ->
        new_state = Map.put(state, from, strength)
        all_memories_high = Map.values(new_state) |> Enum.all?(fn x -> x == :hi end)
        out_strength = if all_memories_high, do: :lo, else: :hi
        new_config = Map.put(config, to, {:conj, new_state, outbounds})
        {new_config, queue ++ Enum.map(outbounds, fn o -> {to, out_strength, o} end)}

      nil -> {config, queue}
    end

    if queue == [] do
      {:halt, config}
    else
      {:cont, {config, queue}}
    end
  end) |> IO.inspect(label: "\nnext config")
end)

[hi: hi_count] = :ets.lookup(:pulsecount, :hi)
[lo: lo_count] = :ets.lookup(:pulsecount, :lo)
IO.inspect(hi_count, label: "high pulses")
IO.inspect(lo_count, label: "low pulses")
IO.inspect(lo_count * hi_count, label: "answer")

IEx.pry()
