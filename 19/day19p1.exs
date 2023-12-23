require IEx

{:ok, contents} = File.read("input.txt")

[workflows, parts] =
  contents
  |> String.split("\n\n", trim: true)

workflows = workflows
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [_, name, flow] = Regex.run(~r/(.*){(.*)}/, line)
    flow = String.split(flow, ",")
    flow = Enum.map(flow, fn item ->
      if String.contains?(item, ":") do
        String.split(item, ":") |> List.to_tuple()
      else
        item
      end
    end)
    {name, flow}
  end)
  |> Map.new()
  # |> IO.inspect()

parts = parts
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [_, x, m, a, s] = Regex.run(~r/{x=(\d+),m=(\d+),a=(\d+),s=(\d+)}/, line)
    i = fn x -> String.to_integer(x) end
    %{x: i.(x), m: i.(m), a: i.(a), s: i.(s)}
  end)

Enum.map(parts, fn part ->
  IO.write("\n#{inspect(part)}   in")
  fate = Enum.reduce_while(Stream.cycle([0]), "in", fn _, workflow_name ->
    workflow = workflows[workflow_name]
    next_workflow = Enum.reduce_while(workflow, nil, fn rule, _ ->
      case rule do
        {condition, next} ->
          [_, var, op, right] = Regex.run(~r/(.)(.)(\d+)/, condition)
          right = String.to_integer(right)
          op = if op == "<", do: &Kernel.</2, else: &Kernel.>/2
          left = case var do
            "x" -> part.x
            "m" -> part.m
            "a" -> part.a
            "s" -> part.s
          end
          if op.(left, right) do
            # IO.puts("Rule #{condition} failed, next rule...")
            {:halt, next}
          else
            {:cont, nil}
          end

        next -> {:halt, next}
      end
    end)
    IO.write(" -> #{next_workflow}")

    case next_workflow do
      "A" -> {:halt, :accepted}
      "R" -> {:halt, :rejected}
      next_workflow -> {:cont, next_workflow}
    end
  end)
  {part, fate}
end)
|> Enum.filter(fn {_, fate} -> fate == :accepted end)
|> IO.inspect(label: "\naccepted")
|> Enum.map(fn {part, _} -> part.x + part.m + part.a + part.s end)
|> Enum.sum()
|> IO.inspect(label: "sum")

IEx.pry()
