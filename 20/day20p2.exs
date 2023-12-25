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

:ets.new(:almost_trips, [:named_table, :public])
:ets.insert(:almost_trips, {"dl", []})
:ets.insert(:almost_trips, {"ks", []})
:ets.insert(:almost_trips, {"pm", []})
:ets.insert(:almost_trips, {"vk", []})

Enum.reduce_while(1..80000, config, fn i, config ->
  if rem(i, 10000) == 0 do
    IO.puts("#{i}th iteration")
  end
  out = Enum.reduce_while(Stream.cycle([0]), {config, [{"button", :lo, "broadcaster"}]}, fn _, {config, [next | queue]} ->
    {from, strength, to} = next
    # IO.puts("#{from} -#{strength}-> #{to}")

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

    if to == "dt" do
      state = elem(target, 1)
      Enum.filter(state, fn {_, v} -> v == :hi end) |> Enum.map(fn {k, _} ->
        [{_, arr}] = :ets.lookup(:almost_trips, k)
        :ets.insert(:almost_trips, {k, arr ++ [i]})
      end)
    end

    cond do
      to == "rx" and strength == :lo ->
        IO.inspect(i)
        {:halt, nil}
      queue == [] -> {:halt, config}
      true -> {:cont, {config, queue}}
    end
  end) #|> IO.inspect(label: "\nnext config")
  if out do
    {:cont, out}
  else
    {:halt, nil}
  end
end)

[{_, dl}] = :ets.lookup(:almost_trips, "dl")
[{_, ks}] = :ets.lookup(:almost_trips, "ks")
[{_, pm}] = :ets.lookup(:almost_trips, "pm")
[{_, vk}] = :ets.lookup(:almost_trips, "vk")
moments = [dl, ks, pm, vk]
moments = Enum.map(moments, fn m -> Enum.uniq(m) end)
IO.inspect(moments)

values = Enum.map(moments, fn m ->
  Enum.map_reduce(m, 0, fn x, acc ->
    {x - acc, x}
  end) |> elem(0)
end)
  |> IO.inspect(charlists: :as_lists)
  |> Enum.map(fn [x | _] -> x end)
  |> List.to_tuple()
  |> IO.inspect()
  |> Tuple.product() # confirmed their GCD is 1
  |> IO.inspect(label: "answer")

IEx.pry()
