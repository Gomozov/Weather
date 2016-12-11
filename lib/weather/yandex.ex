defmodule Weather.Yandex do
  import Weather.TableFormatter, only: [print_table_for_columns: 2]
  use HTTPoison.Base

  @default_adress "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22nome%2C%20ak%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
  @expected_fields ~w(
                      atmosphere forecast item
                     )

  def main() do
    @default_adress
    |> fetch
    |> process_response_body
  end

  def fetch(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> body
      {:ok, %HTTPoison.Response{status_code: 404}}             -> IO.puts "Not found :("
      {:ok, %HTTPoison.Response{body: body}}                   -> IO.puts body
      {:error, %HTTPoison.Error{reason: reason}}               -> IO.inspect reason
    end
  end

  def convert_to_map(list) do
    list
    |> Enum.map(&Enum.into(&1, HashDict.new))
  end


  def process_response_body(body) do
    body
    |> Poison.decode!
    |> get_in(["query", "results", "channel", "item", "forecast"])
    |> print_table_for_columns(["date", "day", "high", "low", "text"])
# |> Map.get("query")
#   |> Map.get("results")
#   |> Map.get("channel")
#   |> Map.get("item")
#   |> Map.get("forecast")
#   |> Enum.map(fn (x) -> x["date"] end)
# |> Map.take(@expected_fields)
#|> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

end

