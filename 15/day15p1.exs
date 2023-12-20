require IEx

import IO.ANSI

{:ok, contents} = File.read("input.txt")

out =
  contents
  |> String.split("\n", trim: true)
  |> Enum.at(0)
  |> String.split(",", trim: true)
  |> Enum.map(fn string ->
    string = string |> to_charlist
    IO.inspect(string)
    Enum.reduce(string, 0, fn char, acc ->
      acc = acc + char
      acc = acc * 17
      acc = rem(acc, 256)
      acc
    end) |> IO.inspect()
  end)
  |> IO.inspect()
  |> Enum.sum
  |> IO.inspect(label: "final")

IEx.pry()
