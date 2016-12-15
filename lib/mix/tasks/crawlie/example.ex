defmodule Mix.Tasks.Crawlie.Example do
  use Mix.Task

  @moduledoc """
  Runs the simple crawlie example.

  Usage:
      mix crawlie.example https://some.address.com/ google.com http://one-more.org/
  """

  @shortdoc "run crawlie example"
  def run(args) do
    IO.puts "Running crawlie example:"
    IO.puts ""

    urls = case args do
      [] ->
        IO.puts "No arguments provided, crawling `google.com` and `https://mainframe.com/`."
        IO.puts ""
        ["google.com", "https://mainframe.com/"]
      _ -> args
    end

    # this is just a Task, the needed application needs to be started manually
    {:ok, _started} = Application.ensure_all_started(:crawlie)

    # the third argument of Crawlie.crawl! contains both the crawlie custom options
    # and HTTPoison options
    results = Crawlie.crawl!(urls, CrawlieExample.TitleLogic, [follow_redirect: true, timeout: 7000])

    results
      |> Enum.map(&("title tag: " <> &1))
      |> Enum.each(&IO.puts/1)
  end
end
