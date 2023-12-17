require IEx
use Bitwise

{:ok, contents} = File.read("input.txt")

vals =
  contents
  |> String.split("\n", trim: true)
  # |> Enum.take(1)
  |> Enum.map(fn s ->
    [log, conts] = String.split(s, " ", trim: true)
    conts = String.split(conts, ",") |> Enum.map(&String.to_integer/1)

    unknown_count = String.graphemes(log) |> Enum.count(fn c -> c == "?" end)

    IO.puts("#{log} has #{unknown_count} ?s. Correct conts is #{inspect(conts)}. Trying...")
    for binval <- 0..Integer.pow(2, unknown_count)-1 do
      possibility = String.graphemes(log)
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

      possibility_conts = Stream.chunk_by(possibility, &(&1))
        |> Stream.map(fn chunk ->
          if List.first(chunk) == "#", do: length(chunk), else: nil
        end)
        |> Stream.reject(&is_nil/1)
        |> Enum.to_list()

      matches = conts == possibility_conts
      match_str = if matches, do: "MATCHES!", else: ""
      # IO.puts("Possibility #{Enum.join(possibility)} has conts #{inspect(possibility_conts, charlists: :as_lists)}  #{match_str}")
      if matches, do: 1, else: 0

    end |> Enum.sum |> IO.inspect(label: "arrangements")
  end)
  |> IO.inspect(label: "arrangements array")
  |> Enum.sum()
  |> IO.inspect(label: "sum")


IEx.pry()
