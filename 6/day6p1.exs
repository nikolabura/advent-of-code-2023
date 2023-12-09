require IEx

{:ok, contents} = File.read("input.txt")

input =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    Regex.scan(~r/\d+/, line)
      |> Enum.map(fn [n] -> String.to_integer(n) end)
  end)
  |> Enum.zip

out =
  input
  |> Enum.map(fn {time_length, record_distance} ->
    IO.puts("Race lasts for #{time_length}ms and record is #{record_distance}mm.")
    ways_to_win =
      Enum.map(0..time_length, fn hold_for ->
        mm_per_sec = hold_for
        remaining_time = time_length - hold_for
        moved_dist = remaining_time * mm_per_sec
        # IO.puts("Hold button for #{hold_for}ms, get #{remaining_time}ms to move, so moved for #{moved_dist}mm.")
        beats_record = moved_dist > record_distance
        beats_record
      end)
      |> Enum.filter(fn x -> x end)
      |> Enum.count()
  end)
  |> IO.inspect()
  |> Enum.reduce(fn x, acc -> x * acc end)
  |> IO.inspect()

IEx.pry()
