defmodule CrawlieExample.TitleLogic do
  use Crawlie.ParserLogic

  def extract_data(body) do
    # Remember not to parse HTML with regex! http://stackoverflow.com/a/1732454/246337
    case Regex.run(~r/<title>([^<>]*)<\/title>/ims, body, capture: :all_but_first) do
      nil -> "no title recognized"
      [title] ->
        title
          |> String.to_charlist
          # in case the title isn't a valid UTF-8 string
          |> Enum.filter(fn(c) -> c >= 32 and c <= 126 end)
          |> to_string
          |> List.wrap
    end

  end


end
