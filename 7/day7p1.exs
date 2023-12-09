require IEx

{:ok, contents} = File.read("input.txt")

input =
  contents
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " "))
  |> Enum.map(fn [hand, bid_str] ->
    bid = String.to_integer(bid_str)

    freqs = String.graphemes(hand)
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort()
      |> Enum.reverse()

    type =
      case freqs do
        [5] -> :five_kind
        [4, 1] -> :four_kind
        [3, 2] -> :full_house
        [3, 1, 1] -> :three_kind
        [2, 2, 1] -> :two_pair
        [2, 1, 1, 1] -> :one_pair
        [1, 1, 1, 1, 1] -> :high_card
      end
    IO.puts("Hand #{hand} is #{type}.")

    {hand, type, bid}
  end)
  |> Enum.sort(fn {greater_hand, greater_type, _}, {lesser_hand, lesser_type, _} ->
    type_score = fn type ->
      case type do
        :five_kind -> 9
        :four_kind -> 8
        :full_house -> 7
        :three_kind -> 6
        :two_pair -> 5
        :one_pair -> 4
        :high_card -> 3
      end
    end

    if type_score.(greater_type) != type_score.(lesser_type) do
      type_score.(greater_type) >= type_score.(lesser_type)
    else
      # need to compare strings
      IO.write("Is #{greater_hand} > #{lesser_hand}... ")
      zipped = Enum.zip([String.graphemes(greater_hand), String.graphemes(lesser_hand)])
      results = Enum.map(zipped, fn {greater, lesser} ->
        order = String.graphemes("23456789TJQKA")
        greater_rank = Enum.find_index(order, &(&1 == greater))
        lesser_rank  = Enum.find_index(order, &(&1 == lesser))
        cond do
          greater_rank > lesser_rank -> true
          greater_rank < lesser_rank -> false
          true -> nil
        end
      end) |> Enum.reject(&is_nil/1) |> Enum.at(0)
      IO.inspect(results)
    end
  end)
  |> Enum.reverse()
  |> Enum.with_index(1)
  |> Enum.map(fn {{hand, type, bid}, rank} ->
    IO.puts("Rank #{rank}: #{hand} (#{type})")
    bid * rank
  end)
  |> Enum.sum()

IO.inspect(input)

IEx.pry()
