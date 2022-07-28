defmodule LyfDestryr do
  @aad "AES256GCM"

  @doc """
  Generates a random base64 encoded secret key.
  """
  def generate_secret do
    :crypto.strong_rand_bytes(16)
    |> :base64.encode
  end


  @doc """
  Takes in two arguments: the value to be encrypted and the secret key to encrypt it with.
  """
  def do_encrypt(val, key) do
    # using the Advanced Encryption Standard Galois Counter Mode
    mode = :aes_gcm
    # converts the key to binary
    secret_key = :base64.decode(key)
    # generates an initialization vector
    iv = :crypto.strong_rand_bytes(16)
    # ???
    {ciphertext, ciphertag} = :crypto.block_encrypt(mode, secret_key, {@aad, to_string(val), 16})
    iv <> ciphertag <> ciphertext
  end


  # def hashKey(str) do
  #   :crypto.hash(:sha256,str)
  #   |> Base.encode16() \
  #   |> String.downcase()
  # end


  @doc """
  Sort the numbers found in each of the lines
  Keep the order of the lines as it is
  """
  def encrypt_file(in_filename, out_filename) do
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
    secret = LyfDestryr.generate_secret
    line
    # Separate the tokens at the spaces. This creates a list
    |> String.split()
    |> Enum.map(&do_encrypt(&1, secret))
    # Joint the strings in the list into a single string
    |> Enum.join(" ")
  end
end
