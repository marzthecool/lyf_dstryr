# secret = LyfDestryr.generate_secret
# LyfDestryr.do_decrypt("R0NklEhjgtHljd4U1bcPbHhdVzbJHiiFbC3IydA8Hj34JeMrypmoJbmJBw==", secret)
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
    {ciphertext, ciphertag} = :crypto.block_encrypt(mode, secret_key, iv, {@aad, to_string(val), 16})
    iv <> ciphertag <> ciphertext
    |> :base64.encode
  end

  @doc """
  Takes in an argument of the ciphertext and the secret key that was used to encrypt it.
  """
  def do_decrypt(ciphertext, key) do
    mode = :aes_gcm
    secret_key = :base64.decode(key)
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    :crypto.block_decrypt(mode, secret_key, iv, {@aad, ciphertext, tag})
  end


  @doc """
  Sort the numbers represented as a string, by converting them
  to a list, sorting, then converting back to a string
  """
  def sort_lines(line, mode) do
    secret = LyfDestryr.generate_secret
    # Separate the tokens at the spaces. This creates a list
    # word_list = String.split(line)
    cond do
      mode == "encrypt" ->
        do_encrypt(line, secret)
      mode == "decrypt" ->
        do_decrypt(line, secret)
    end
  end


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
      |> Enum.map(&sort_lines(&1, "encrypt"))
      # Join all the lines into a single string separated with New Line characters
      |> Enum.join("\n")
    # Store the final string into the file
    File.write(out_filename, new_text)
  end


  @doc """
  Sort the numbers found in each of the lines
  Keep the order of the lines as it is
  """
  def decrypt_file(in_filename, out_filename) do
    new_text = in_filename
      # Read the file line by line
      |> File.stream!()
      # Remove trailing spaces around each line
      |> Enum.map(&String.trim/1)
      # Apply the function below to each line
      |> Enum.map(&sort_lines(&1, "decrypt"))
      # Join all the lines into a single string separated with New Line characters
      |> Enum.join("\n")
    # Store the final string into the file
    File.write(out_filename, new_text)
  end
end
