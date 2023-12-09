require IEx

defmodule AlRange do
  defstruct src_start: 0, dst_start: 0, len: 0
end

defmodule Main do
  def main do
    {:ok, contents} = File.read("input.txt")

    [seeds | maps] =
      contents
      |> String.split("\n\n", trim: true)

    [_, seeds] = Regex.run(~r/:([ \d]+)/, seeds)
    seeds = String.split(seeds, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, len] ->
        start .. start+len-1
      end)

    IO.inspect(seeds, label: "initial seeds", charlists: :as_lists)

    maps = Enum.map(maps, fn map ->
      [name | lines] = String.split(map, "\n", trim: true)
      lines = Enum.map(lines, fn line ->
        [n1, n2, n3] = String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
        %AlRange{dst_start: n1, src_start: n2, len: n3}
      end)
      {name, lines}
    end)

    #IO.inspect(maps, label: "maps", charlists: :as_lists)

    Enum.map(seeds, fn seed_range ->
      location = Enum.reduce(maps, [seed_range], fn {mapname, map}, in_ranges ->
        IO.inspect(mapname, label: "mapname")

        out_ranges = Enum.map(in_ranges, fn in_range ->
          IO.inspect(in_range, label: "  in range")
          # IO.puts("Checking #{inspect(in_range)} against #{inspect(map_range)}")

          tokens =
            Enum.map(map, fn map_line ->
              #IO.puts("   There's a range from #{map_line.src_start} to #{map_line.src_start + map_line.len - 1} inclusive.")
              [
                {map_line.src_start, :start},
                {map_line.src_start + map_line.len - 1, :end}
              ]
            end) ++ [
              {in_range.first, :start},
              {in_range.last, :end}
            ]
            |> List.flatten()
            |> Enum.sort_by(fn {n, _} -> n end)
            # |> IO.inspect(charlists: :as_lists)
            |> Enum.reject(fn {n, _} -> n < in_range.first end)
            |> Enum.reject(fn {n, _} -> n > in_range.last end)
          # IO.inspect(tokens, charlists: :as_lists)

          tokens = Enum.reduce(tokens, [], fn next_token, acc ->
            prev = Enum.at(acc, -1)
            case {prev, next_token} do
              {nil, _} -> [next_token]
              {{_ps, :start}, {ns, :start}} -> acc ++ [{ns - 1, :end}, next_token]
              {{_ps, :start}, {_ns, :end}} -> acc ++ [next_token]
              {{ps, :end}, {ns, :start}} ->
                if ps == ns - 1 do
                  acc ++ [next_token]
                else
                  acc ++ [{ps + 1, :end}, next_token]
                end
              {{ps, :end}, {_ns, :end}} -> acc ++ [{ps + 1, :start}, next_token]
            end
          end)
          # IO.inspect(tokens, charlists: :as_lists)

          ranges = Enum.chunk_every(tokens, 2)
            |> Enum.map(fn [{sn, :start}, {en, :end}] ->
              sn..en
            end)
          IO.inspect(ranges, charlists: :as_lists, label: "  chopped ranges")

          out_ranges = Enum.map(ranges, fn chopped_range ->
            found = Enum.find(map, fn map_line ->
              chopped_range.first >= map_line.src_start
                and chopped_range.last <= map_line.src_start + map_line.len - 1
            end)
            if found do
              map_offset = found.dst_start - found.src_start
              maps_to = chopped_range.first + map_offset .. chopped_range.last + map_offset
              IO.puts("   choppedrange #{inspect(chopped_range)} fits in #{inspect(found)} and maps to #{inspect(maps_to)}")
              maps_to
            else
              IO.puts("   choppedrange #{inspect(chopped_range)} doesn't fit anywhere, goes unchanged")
              chopped_range # range unchanged
            end
          end)
          out_ranges
        end) |> List.flatten()
        IO.inspect(out_ranges, charlists: :as_lists, label: "  out ranges")
        IO.puts("")
        out_ranges
      end)

      IO.puts("Seed #{inspect(seed_range)} -> location #{inspect(location)}\n")
      location
    end)
    |> List.flatten()
    |> IO.inspect(label: "all locations")
    |> Enum.map(fn x..y -> x end)
    |> IO.inspect(charlists: :as_lists, label: "firsts")
    |> Enum.min()
    |> IO.inspect(label: "MIN")

    IEx.pry()
  end
end

Main.main()
