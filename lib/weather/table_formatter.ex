defmodule Weather.TableFormatter do
  import Enum, only: [ each: 2, map: 2, map_join: 3, max: 1 ]

  def print_table_for_columns(rows, headers) do
    data_by_columns         = split_into_columns(rows, headers)       #объединение сырых данных в столбцы
    data_with_headers       = add_headers(data_by_columns, headers)   #добавление заголовков к столбцам
    column_widths           = widths_of(data_with_headers)            #определение максимальной ширины столбца
    format                  = format_for(column_widths)               #формат для заголовка
    formatted_columns       = split_into_map(column_widths, data_by_columns) #Map из форматов и строк
    puts_one_line_in_columns  headers, format                         #Форматируем и печатаем заголовки
    IO.puts                   separator(column_widths)                #Печатаем разделитель
    puts_in_columns           formatted_columns                       #Форматируем и печатаем строки
    IO.puts                   separator(column_widths)                #Печатаем разделитель
  end

  def split_into_map(column_width, columns) do
    columns
    |> List.zip
    |> map(&Tuple.to_list/1)
    |> Enum.zip(List.duplicate(column_width, Kernel.length(List.first(columns))))
    |> Enum.into(%{}) 
    |> Enum.map(fn {str, format} -> coloring(str, format) end)
  end

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  def printable(str) when is_binary(str), do: str

  def add_headers(columns, headers) do
   Enum.zip(headers, columns) |> Enum.into(%{}) |> Enum.map(fn {k, v} -> [k | v] end)
  end

  def widths_of(columns) do
    for column <- columns, do: column |> map(&String.length/1) |> max
  end

  def format_for(column_widths) do
    map_join(column_widths, " | ", fn width -> "~-#{width}s" end) <> "~n"
  end

  def separator(column_widths) do
    map_join(column_widths, "-+-", fn width -> List.duplicate("-", width) end)
  end

  def puts_in_columns(columns) do
    columns
    |> map(fn {k, v} -> puts_one_line_in_columns(k, v) end)
  end

  def coloring(str, column_width) do
    #["18 Dec 2016", "Sun", "0", "-3", "Cloudy"], [11, 3, 4, 3, 13]
    Enum.zip(str, column_width)
    |> Enum.map(&validate(&1))
    |> List.zip
    |> split
    #{["18 Dec 2016", "Sun", "0", "-3", "Cloudy"], "~-11s | ~-3s | ~-4s | ~-3s | ~-13s~n"}
  end
  
  def split([head, tail]) do
    {Tuple.to_list(head), Enum.join(Tuple.to_list(tail), " | ") <> "~n"}
  end

  def validate({x, y}) do
    cond do
      String.equivalent?(x, "Sun") -> {x, "\e[31m\e[1m" <> "~-#{y}s" <> "\e[0m"}
      String.equivalent?(x, "Sat") -> {x, "\e[31m\e[1m" <> "~-#{y}s" <> "\e[0m"}
      String.contains?(x, "-")     -> {x, "\e[34m\e[1m" <> "~-#{y}s" <> "\e[0m"}
      true                         -> {x, "~-#{y}s"}
    end
  end

  def puts_one_line_in_columns(fields, format) do
    :io.fwrite(format, fields)
  end

end
