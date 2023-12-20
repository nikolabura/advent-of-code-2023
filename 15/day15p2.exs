require IEx

# import IO.ANSI

{:ok, contents} = File.read("input.txt")

hash = fn string ->
  Enum.reduce(string |> to_charlist, 0, fn char, acc ->
    acc = acc + char
    acc = acc * 17
    acc = rem(acc, 256)
    acc
  end)
end

out =
  contents
  |> String.split("\n", trim: true)
  |> Enum.at(0)
  |> String.split(",", trim: true)
  |> Enum.reduce(%{}, fn step, map ->
    [label, len_str] = String.split(step, ~r/[-=]/)
    label_hash = hash.(label)
    IO.inspect([step, label, label_hash, len_str])
    map_out = if String.contains?(step, "=") do
      len = String.to_integer(len_str)
      box = Map.get(map, label_hash, [])
      box = if target_index = Enum.find_index(box, fn {item_label, _} -> label == item_label end) do
        # lens with this label is already in box
        List.replace_at(box, target_index, {label, len})
      else
        # new lens label
        box ++ [{label, len}]
      end
      Map.put(map, label_hash, box) #TODO replace if label dup
    else
      if box = Map.get(map, label_hash) do
        box = box |> Enum.reject(fn {item_label, _} -> label == item_label end)
        Map.put(map, label_hash, box)
      else
        map
      end
    end
    IO.inspect(map_out)
    IO.puts("")
    map_out
  end)
  |> Enum.map(fn {boxnum, box} ->
    if length(box) > 0 do
      IO.write("Box #{boxnum}: ")
      for {label, focal} <- box do
        IO.write("[#{label} #{focal}] ")
      end
      IO.puts("")

      box
        |> Enum.with_index()
        |> Enum.map(fn {{_, focal}, index} ->
          (boxnum + 1) * (index + 1) * focal
        end)
        # |> IO.inspect()
        |> Enum.sum()
    else
      0
    end
  end)
  |> Enum.sum()
  |> IO.inspect(label: "\nfinal")

IEx.pry()
