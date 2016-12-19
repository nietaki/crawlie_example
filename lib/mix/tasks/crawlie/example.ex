defmodule Mix.Tasks.Crawlie.Example do
  use Mix.Task

  alias Experimental.Flow

  @moduledoc """
  Runs the simple crawlie example.

  Usage:
      mix crawlie.example https://some.address.com/ google.com http://one-more.org/
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
      url_manager_timeout: 5000,
      min_demand: 1,
      max_demand: 5,
    ]

    results = Crawlie.crawl(urls, CrawlieExample.WordCountLogic, options)
    results = results
      |> Enum.reduce(%{}, &count_word/2)
      # alternatively, instead of the above Enump pipelines, it is possible to do more performant Flow operations
      # |> Flow.reduce(&Map.new/0, &count_word/2)
      # |> Flow.departition(&Map.new/0, &map_merge/2, &(&1))
      # |> Enum.to_list
      # |> hd
      |> Enum.map(fn {word, count} -> {count, word} end)
      |> Enum.sort
      |> Enum.reverse
      |> Enum.take(30)

    IO.puts "most popular words longer than 4 letters in the vicinity of #{inspect urls}:"
    IO.puts "{count, word}"
    IO.puts "============="
    Enum.each(results, fn(tuple) -> IO.puts inspect(tuple) end)
  end

  def count_word(word, map) do
    Map.update(map, word, 1, &(&1 + 1))
  end

  def map_merge(m1, m2) do
    Map.merge(m1, m2, fn(_k, v1, v2) -> v1 + v2 end)
  end
end
