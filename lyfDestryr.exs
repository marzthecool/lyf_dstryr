#
# Final Project
# Course: Programming Languages
#
# Mary Laura Carmona Martínez - A01732035
# Arturo Montes de Oca Barrios A01732697
#
# 2022-07-28
#
# Run using:
# LyfDestryr.main("./Data/Test_#.txt", "./Encrypted/Test_#_ENCRYPTED.txt", "encrypt")
# LyfDestryr.main("./Encrypted/Test_#_ENCRYPTED.txt", "./Decrypted/Test_#_DECRYPTED.txt", "decrypt")
#

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
    # does encryption
    {ciphertext, ciphertag} = :crypto.block_encrypt(mode, secret_key, iv, {@aad, to_string(val), 16})
    # concatenates
    iv <> ciphertag <> ciphertext
    # converts the result to binary
    |> :base64.encode
  end

  @doc """
  Takes in two arguments: the encrypted text and the secret key that was used to encrypt it.
  """
  def do_decrypt(ciphertext, key) do
    # using the Advanced Encryption Standard Galois Counter Mode
    mode = :aes_gcm
    # converts the key to binary
    secret_key = :base64.decode(key)
    # converts the encrypted text to binary
    ciphertext = :base64.decode(ciphertext)
    # uses pattern matching to extract the initialization vector, ciphertext and ciphtertag from the encrypted and encoded value we passed into decrypt
    <<iv::binary-16, tag::binary-16, ciphertext::binary>> = ciphertext
    # does decryption
    :crypto.block_decrypt(mode, secret_key, iv, {@aad, ciphertext, tag})
  end


  @doc """
  Takes a string with the full path to a file and reads its contents.
  """
  def read_contents(in_path) do
    # finds path
    Path.expand(in_path)
    # reads the file line by line
    |> File.stream!()
    # removes trailing spaces around each line
    |> Enum.map(&String.trim/1)
  end


  @doc """
  Takes a string that's the generated secret key, and a string with the full path to a file where the key will be kept.
  Returns a .txt file
  """
  def store_key(secret, out_path) do
    File.write(out_path, secret)
  end


  @doc """
  Takes in two arguments: a list with the data to be processed and the mode that indicates whether the file is being encrypted or decrypted.
  """
  def process_data(data, mode) do
    cond do
      mode == "encrypt" ->
        # generates key
        secret = LyfDestryr.generate_secret
        # saves key
        store_key(secret, "./Key/key.txt")
        # calls encrypt function for each line
        Enum.map(data, fn line -> do_encrypt(line, secret) end)

      mode == "decrypt" ->
        # calls encrypt function
        key = LyfDestryr.read_contents("./Key/key.txt") |> List.to_string
        # calls decrypt function for each line
        Enum.map(data, fn line -> do_decrypt(line, key) end)
    end
  end


  @doc """
  Takes a list with the data, and a string with the full path to a file.
  Returns a .txt file
  """
  def store_txt(data, out_path) do
    text_data =
      data |> Enum.join("\n")
    File.write(out_path, text_data)
  end


  @doc """
  Takes two arguments: a string with the full path to a folder containing files to read, and another to a folder where the results will be stored.
  Will call all the other functions, to read the data, generate new data and write it into a new file.
  """
  def main(in_path, out_path, mode) do
    data = read_contents(in_path)
    processed_data = process_data(data, mode)
    store_txt(processed_data, out_path)
  end
end
