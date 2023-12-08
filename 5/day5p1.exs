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

    IO.inspect(seeds, label: "initial seeds")

    maps = Enum.map(maps, fn map ->
      [name | lines] = String.split(map, "\n", trim: true)
      lines = Enum.map(lines, fn line ->
        [n1, n2, n3] = String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
        %AlRange{dst_start: n1, src_start: n2, len: n3}
      end)
      {name, lines}
    end)

    #IO.inspect(maps, label: "maps", charlists: :as_lists)

    Enum.map(seeds, fn seed ->
      location = Enum.reduce(maps, seed, fn {mapname, map}, in_value ->
        # IO.inspect(mapname, label: "mapname")
        # IO.inspect(in_value, label: "in value")

        out_val = Enum.map(map, fn range ->
          fits = in_value in range.src_start .. range.src_start + range.len - 1
          if fits do
            (in_value - range.src_start) + range.dst_start
          else
            nil
          end
        end) |> Enum.reject(&is_nil/1) |> List.flatten()

        if Enum.count(out_val) > 0 do
          Enum.at(out_val, 0)
        else
          in_value
        end
      end)

      IO.puts("Seed #{seed} -> location #{location}")
      location
    end)
    |> Enum.min()
    |> IO.inspect(label: "min")


    IEx.pry()
  end
end

Main.main()
