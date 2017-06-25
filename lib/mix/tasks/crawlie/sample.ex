defmodule Mix.Tasks.Crawlie.Sample do
  use Mix.Task

  @shortdoc "run the samples to be used in the presentation"

  def run(_args) do
    # basic()
    advanced()
  end

  def basic() do
    File.stream!("input.txt")
    #
    |> Stream.flat_map(&String.split/1)
    |> Enum.reduce(%{}, fn word, map ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
    |> Enum.each(&IO.inspect/1)


    File.close("input.txt")

    IO.puts "flow now"

    File.stream!("input.txt")
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, map ->
      Map.update(map, word, 1, &(&1 + 1))
    end)
    |> Flow.each(&IO.inspect/1)
    |> Enum.to_list() # or Flow.run()
    # |> Flow.run()



    # IO.puts "### ANOTHER"
    # |> Flow.partition()

    Stream.cycle([:a, :b, :c])
    |> Stream.take(3_000_000)
    |> Flow.from_enumerable(max_demand: 256)
    |> Flow.reduce(fn -> %{} end, fn atom, map ->
      Map.update(map, atom, 1, &(&1 + 1))
    end)
    |> Enum.into(%{})
    |> IO.inspect()

    Stream.cycle([:a, :b, :c])
    |> Stream.take(3_000_000)
    |> Flow.from_enumerable(max_demand: 256)
    |> Flow.reduce(fn -> %{} end, fn atom, map ->
      Map.update(map, atom, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
    |> IO.inspect()
    # |> Enum.reduce(%{}, fn {atom, count}, map ->
      # Map.update(map, atom, count, &(&1 + count))
    # end)
    # |> IO.inspect

    Stream.cycle([:a, :b, :c])
    |> Stream.take(3_000_000)
    |> Flow.from_enumerable(max_demand: 256)
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn atom, map ->
      Map.update(map, atom, 1, &(&1 + 1))
    end)
    |> Enum.into(%{})
    |> IO.inspect

  end

  def advanced() do

    f = Flow.from_enumerable(1..10)

    creator_pid = self()
    {:ok, consumer} = GenStage.start_link(NosyStage, creator_pid)
    {:ok, _coordinator_process} = Flow.into_stages(f, [{consumer, [max_demand: 8]}])

    receive do
      :nosy_stage_done -> IO.puts "RESULT: nosy stage done"
    after
      1000 -> IO.puts "RESULT: nosy stage never finished"
    end

    Process.sleep(1000)
  end
end
