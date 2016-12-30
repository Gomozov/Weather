defmodule Weather.Yahoo do
  import Weather.TableFormatter, only: [print_table_for_columns: 2]
  use HTTPoison.Base

  def get_forecast(link) do 
    link
    |> fetch
    |> process_response_body
  end

  def fetch(url) do
    case HTTPoison.get(url, [], [recv_timeout: 10000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}  -> body
      {:ok, %HTTPoison.Response{status_code: 404}}              -> correct_stop "Not found"
      {:ok, %HTTPoison.Response{body: body}}                    -> correct_stop body
      {:error, %HTTPoison.Error{reason: reason}}                -> correct_stop reason
    end
  end

  def check_results(body) do
    result = get_in(body, ["query", "results"])
    case result do
      nil     -> correct_stop "Null from Yahoo"
      _       -> result
    end
  end

  def correct_stop(message) do
    IO.write("\e[33m\e[1mFrom #{Kernel.inspect(self)}\e[0m: ")
    IO.inspect message
    Process.exit(self, :kill)
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> check_results
    |> get_in(["channel", "item"])
    |> print_table_for_columns(["date", "day", "high", "low", "text"])
  end

end
