defmodule Tfiles do

  @doc """
  Sort the numbers found in each of the lines
  Keep the order of the lines as it is
  """
  def sort_file_numbers(in_filename, out_filename) do
    new_text = in_filename
      # Read the file line by line
      |> File.stream!()
      # Remove trailing spaces around each line
      |> Enum.map(&String.trim/1)
      # Apply the function below to each line
      |> Enum.map(&sort_lines(&1))
      # Join all the lines into a single string separated with New Line characters
      |> Enum.join("\n")
    # Store the final string into the file
    File.write(out_filename, new_text)
  end

  @doc """
  Sort the numbers represented as a string, by converting them
  to a list, sorting, then converting back to a string
  """
  def sort_lines(line) do
    line
    # Separate the tokens at the spaces. This creates a list
    |> String.split()

    |> Enum.map(&str_to_bi(&1))

    # Joint the strings in the list into a single string
    |> Enum.join(" ")

  end

  def str_to_bi(line) do
    line
    # Convert string line its binary value
    |> String.to_charlist()
  end

end
