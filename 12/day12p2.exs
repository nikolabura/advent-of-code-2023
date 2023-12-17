require IEx
use Bitwise

defmodule Rec do
  def count_conts([first_chunk_choices | onwards_chunks], remaining_necessary) do
    Enum.map(first_chunk_choices, fn try_choice ->
      if List.starts_with?(remaining_necessary, try_choice) do
        # IO.inspect(try_choice, label: "works so far")
        # IO.inspect(remaining_necessary, label: "remaining necessary")
        next_remaining = Enum.drop(remaining_necessary, length(try_choice))
        valid_from_here = count_conts(onwards_chunks, next_remaining)
        # IO.inspect(valid_from_here, label: "valid onwards")
      else
        0
      end
    end) |> Enum.sum()
  end

  def count_conts([], []) do
    1
  end
end

{:ok, contents} = File.read("input.txt")

vals =
  contents
  |> String.split("\n", trim: true)
  # |> Enum.take(2)
  |> Enum.map(fn s ->
    [log, conts] = String.split(s, " ", trim: true)
    log = List.duplicate(log, 5) |> Enum.join("?")

    conts = String.split(conts, ",") |> Enum.map(&String.to_integer/1)
    conts = List.duplicate(conts, 5) |> List.flatten()

    unknown_count = String.graphemes(log) |> Enum.count(fn c -> c == "?" end)

    IO.puts("LINE: #{log}  Correct conts is #{inspect(conts)}...")

    chunk_possible_conts = String.graphemes(log)
      |> Enum.chunk_by(fn c -> c == "." end)
      |> Enum.reject(fn h -> List.first(h) == "." end)
      # |> IO.inspect(label: "trychunks")
      |> Enum.map_reduce(%{}, fn chunk, cache ->
        unknown_count = Enum.count(chunk, fn c -> c == "?" end)
        IO.puts("#{Enum.join(chunk)} has #{unknown_count} ?s. Bitwise enumerating for conts...")

        possibilities = if Map.has_key?(cache, chunk) do
          cache[chunk]
        else
          for binval <- 0..Integer.pow(2, unknown_count)-1 do
            possibility = chunk
              |> Enum.reduce({0, []}, fn inchar, {unknown_index, outstr} ->
                if inchar == "?" do
                  is_one = ((binval >>> unknown_index) &&& 1) == 1
                  outchar = if is_one, do: "#", else: "."
                  {unknown_index + 1, outstr ++ [outchar]}
                else
                  {unknown_index, outstr ++ [inchar]}
                end
              end)
              |> elem(1)

            Stream.chunk_by(possibility, &(&1))
              |> Stream.map(fn chunk ->
                if List.first(chunk) == "#", do: length(chunk), else: nil
              end)
              |> Stream.reject(&is_nil/1)
              |> Enum.to_list()
          end
        end

        {possibilities, Map.put(cache, chunk, possibilities)}
      end)
      |> elem(0)

    IO.inspect(Enum.map(chunk_possible_conts, fn c -> length(c) end), label: "num of possible conts per chunk")

    count = Rec.count_conts(chunk_possible_conts, conts)
    IO.inspect(count, label: "final count")

    0
  end)
  # |> IO.inspect(label: "arrangements array")
  # |> Enum.sum()
  # |> IO.inspect(label: "sum")


IEx.pry()
