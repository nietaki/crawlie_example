defmodule CrawlieExample.WordCountLogic do
  @behaviour Crawlie.ParserLogic

  alias Crawlie.Response

  def parse(%Response{} = response, _options) do
    # IO.puts "parsing     " <> Response.url(response) 
    case Response.content_type_simple(response) do
      "text/html" ->
        try do
          {:ok, Floki.parse(response.body)}
        rescue
          _e in CaseClauseError -> {:error, :case_clause_error}
          _e in RuntimeError -> {:error, :runtime_error}
        end
      unsupported ->
        IO.puts "Content-Type unsupported by the WordCountLogic: #{unsupported}"
        {:skip, :unsupported_content_type}
    end
  end

  def extract_data(_response, parsed, _options) do
    # IO.puts "extracting  " <> Response.url(response)

    paragraphs = Floki.find(parsed, "p")
    text = Floki.text(paragraphs, sep: " ")
    String.split(text, [" ", "\ "], trim: true)
      |> Enum.filter(&(String.length(&1) > 5))
      |> Enum.map(&String.downcase/1)
  end

  def extract_uris(response, parsed, options) do
    current_uri = response.uri
    hrefs = Floki.attribute(parsed, "a", "href")
    uris = Enum.map(hrefs, &URI.merge(current_uri, &1))

    uris =
    case Keyword.get(options, :domain) do
      domain when is_binary(domain) -> Enum.filter(uris, &(&1.host == domain))
      _ -> uris
    end

    # to show the results of crawlie are consistent
    Enum.reject(uris, fn(uri) -> String.contains?(uri.path || "", "Special:Random") end)
  end
end
