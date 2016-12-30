defmodule Weather.CLI do

  def main(file_name) do
    file_name
    |> File.stream!() 
    |> Stream.map(&String.trim_trailing/1) 
    |> Enum.to_list()
    |> Enum.map(&spawn(Weather.Yahoo, :get_forecast, [&1]))
  end  

end
