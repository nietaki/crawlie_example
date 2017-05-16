defmodule Mix.Tasks.Crawlie.Example do
  use Mix.Task

  alias Flow

  @moduledoc """
  Runs the simple crawlie example.

  Usage:
      mix crawlie.example https://en.wikipedia.org/wiki/Xkcd https://en.wikipedia.org/wiki/Garfield
  """

  @default_urls [
    "https://en.wikipedia.org/wiki/Elixir_(programming_language)",
    "https://en.wikipedia.org/wiki/Mainframe_computer",
  ]

  @shortdoc "run crawlie example"
  def run(args) do
    IO.puts "Running crawlie example:"
    IO.puts ""

    urls = case args do
      [] ->
        IO.puts "No arguments provided, crawling #{inspect @default_urls}."
        IO.puts ""
        @default_urls
      _ -> args
    end

    # this is just a Task, the needed application needs to be started manually
    {:ok, _started} = Application.ensure_all_started(:crawlie)

    # the third argument of Crawlie.crawl! contains both the crawlie custom options
    # and HTTPoison options
    options = [
      max_depth: 1,
      min_demand: 1,
      max_demand: 5,
      fetch_phase: [
        stages: 20,
        min_demand: 1,
        max_demand: 5,
      ],
      process_phase: [
        stages: 8,
        min_demand: 5,
        max_demand: 10,
      ],
      domain: "en.wikipedia.org", # used in WordCountLogic
    ]

    {stats_ref, results} = Crawlie.crawl_and_track_stats(urls, CrawlieExample.WordCountLogic, options)
    stats_printing_task = Task.async(fn -> periodically_dump_stats(stats_ref) end)

    results = results
      |> Flow.partition() # putting same words in same partitions
      |> Flow.reduce(&Map.new/0, &count_word/2)
      |> Flow.departition(&Map.new/0, &map_merge/2, & &1)
      |> Enum.to_list
      |> hd # reduce and departition return in the end a collection of one map
      # ## alternatively, instead of the above Flow pipelines, it is possible do that simpler, in one Enum line:
      # |> Enum.reduce(%{}, &count_word/2)
      |> Enum.reject(fn {_word, count} -> count < 20 end) # rejecting the words with low counts
      |> Enum.sort_by(fn{_word, count} -> count end, &>=/2) # sorting decreasingly
      |> Enum.take(20)

    IO.puts "most popular words longer than 5 letters in the vicinity of #{inspect urls}:"
    IO.puts "{word, count}"
    IO.puts "============="
    Enum.each(results, fn(tuple) -> IO.puts inspect(tuple) end)
    IO.puts ""

    Task.await(stats_printing_task)

    IO.puts "FINAL STATS:"
    IO.inspect(Crawlie.Stats.Server.get_stats(stats_ref))
  end

  def count_word(word, map) do
    Map.update(map, word, 1, &(&1 + 1))
  end

  def map_merge(m1, m2) do
    Map.merge(m1, m2, fn(_k, v1, v2) -> v1 + v2 end)
  end

  def periodically_dump_stats(ref) do
    stats = Crawlie.Stats.Server.get_stats(ref)
    IO.puts "STATS AFTER #{Crawlie.Stats.Server.Data.elapsed_usec(stats) / 1_000_000} SECONDS"
    IO.inspect(stats)
    IO.puts ""
    if Crawlie.Stats.Server.Data.finished?(stats) do
      :ok
    else
      Process.sleep(2000)
      periodically_dump_stats(ref)
    end
  end
end
