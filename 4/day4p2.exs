require IEx

{:ok, contents} = File.read("input.txt")

cardnum_matches =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(fn card ->
    [_, cardnum, winning, have] = Regex.run(~r/(\d+):([ \d]+)\|([ \d]+)/, card)
    cardnum = String.to_integer(cardnum)
    winning = String.split(winning, " ", trim: true) |> MapSet.new
    have    = String.split(have,    " ", trim: true) |> MapSet.new
    intersect = MapSet.intersection(winning, have)
    count = Enum.count(intersect)
    {cardnum, count}
  end)
  |> Map.new

cards_count = Enum.count(cardnum_matches)
card_instances = Enum.map(1..cards_count, fn x -> {x, 1} end) |> Map.new

out = Enum.reduce(1..cards_count, card_instances, fn i, acc ->
  IO.inspect(i, label: "card")
  match_count = IO.inspect(cardnum_matches[i], label: "has matches")
  this_card_instances = acc[i]
  need_copies = if match_count > 0, do: i+1 .. i+match_count, else: []
  IO.inspect(need_copies, label: "need #{this_card_instances} copies of")
  IO.inspect(acc, label: "before")
  acc = Enum.reduce(need_copies, acc, fn copy_card, acc ->
    Map.update!(acc, copy_card, fn val -> val + this_card_instances end)
  end)
  IO.inspect(acc, label: "after")
  IO.puts("")
  acc
end)

IO.inspect(Enum.map(out, fn {_, v} -> v end) |> Enum.sum)

IEx.pry()
