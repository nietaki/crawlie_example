defmodule CrawlieExample.WordCountLogic do
  @behaviour Crawlie.ParserLogic

  def parse(url, body, _options) do
    IO.puts "parsing " <> url

    try do
      {:ok, Floki.parse(body)}
    rescue
      _e in CaseClauseError -> {:error, :case_clause_error}
      _e in RuntimeError -> {:error, :case_clause_error}
    end
  end

  def extract_data(_url, parsed, _options) do
    paragraphs = Floki.find(parsed, "p")
    text = Floki.text(paragraphs, sep: " ")
    String.split(text, [" ", "\ "], trim: true)
      |> Enum.filter(&(String.length(&1) > 4))
      |> Enum.map(&String.downcase/1)
  end

  def extract_links(_url, parsed, _options) do
    hrefs = Floki.attribute(parsed, "a", "href")

    full_urls = Enum.filter(hrefs, &String.starts_with?(&1, ["https://en.wikipedia.org"]))
    wiki_urls = hrefs
      |> Enum.filter(&String.starts_with?(&1, ["/wiki/"]))
      |> Enum.map(&("https://en.wikipedia.org" <> &1))

    full_urls ++ wiki_urls
  end
end
