require IEx
use Bitwise

defmodule Rec do
  def count_conts(run, arg = ["?" | onwards_characters], remaining_necessary) do
    key = {run, arg, remaining_necessary}
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        # IO.inspect(arg, label: "cache hit")
        val
      [] ->
        dot  = count_conts(run, ["."] ++ onwards_characters, remaining_necessary)
        hash = count_conts(run, ["#"] ++ onwards_characters, remaining_necessary)
        out_val = dot + hash
        :ets.insert(:cache, {key, out_val})
        out_val
    end
  end

  def count_conts(_run, [], []) do
    1
  end

  def count_conts(run, [], [one_cont_left]) do
    if one_cont_left == run do
      1
    else
      0
    end
  end

  def count_conts(run, [], conts_left) do
    # IO.inspect(conts_left, label: "conts left and no more string")
    0
  end

  def count_conts(run, string_left, []) do
    if Enum.all?(string_left, fn c -> c == "." or c == "?" end) do
      1
    else
      # IO.inspect(string_left, label: "string left with #s")
      0
    end
  end

  def count_conts(run, arg = ["." | onwards_characters], remaining_necessary) do
    key = {run, arg, remaining_necessary}
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        # IO.inspect(arg, label: "cache hit")
        val
      [] ->
        # IO.puts("#{run}  .#{Enum.join(onwards_characters)}  #{inspect(Enum.take(remaining_necessary, 3))}")
        out = if run == 0 do
          count_conts(0, onwards_characters, remaining_necessary)
        else
          # we just finished a run of several #s
          [should_have_filled | onwards_conts] = remaining_necessary
          if should_have_filled == run do
            count_conts(0, onwards_characters, onwards_conts)
          else
            0
          end
        end
        :ets.insert(:cache, {key, out})
        out
    end
  end

  def count_conts(run, arg = ["#" | onwards_characters], remaining_necessary) do
    key = {run, arg, remaining_necessary}
    case :ets.lookup(:cache, key) do
      [{_, val}] ->
        # IO.inspect(arg, label: "cache hit")
        val
      [] ->
        [dont_fill_more_than | _] = remaining_necessary
        out = if run > dont_fill_more_than do
          0
        else
          count_conts(run + 1, onwards_characters, remaining_necessary)
        end
        :ets.insert(:cache, {key, out})
        out
    end
  end
end

{:ok, contents} = File.read("input.txt")

:ets.new(:cache, [:named_table])

vals =
  contents
  |> String.split("\n", trim: true)
  # |> Enum.slice(6..6)
  # |> Enum.map(&Task.async(fn ->
  |> Enum.map(fn g ->
    [log, conts] = String.split(g, " ", trim: true)
    log = List.duplicate(log, 5) |> Enum.join("?")

    conts = String.split(conts, ",") |> Enum.map(fn x -> String.to_integer(x) end)
    conts = List.duplicate(conts, 5) |> List.flatten()

    IO.puts("LINE: #{log}  Correct conts is #{inspect(conts)}...")

    count = Rec.count_conts(0, String.graphemes(log), conts)
    IO.inspect(count, label: "final count")

    count
  end)
  # |> Enum.map(fn t -> Task.await(t, :infinity) end)
  |> IO.inspect(label: "arrangements array")
  |> Enum.sum()
  |> IO.inspect(label: "sum")


IEx.pry()
