defmodule Mix.Tasks.CrawlieExample do
  use Mix.Task

  @shortdoc "run crawlie example"
  def run(args) do
    urls = args

    # this is just a task, the dependant application needs to be started manually
    {:ok, _started} = Application.ensure_all_started(:crawlie)

    results = Crawlie.crawl!(urls, Crawlie.ParserLogic.Default, [follow_redirect: true])

    results
      |> Stream.map(&String.split_at(&1, 200))
      |> Stream.map(&elem(&1, 0))
      |> Enum.each(fn(beginning) ->
        IO.puts(beginning)
      end)
  end
end
