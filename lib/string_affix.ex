defmodule Experimental.StringAffix do
  alias __MODULE__, as: String

  @type t :: binary

  @doc """
  Prepends `string_left` to `string_right`.

  ## Examples

      # Prepend strings through the pipe-operator
      iex> "Programming" |> String.prepend("Functional")
      "FunctionalProgramming"

      iex> "" |> String.prepend("Functional")
      "Functional"
      
      iex> "Programming" |> String.prepend("")
      "Programming"
      
      iex> "" |> String.prepend("")
      ""
  """
  @spec prepend(String.t, String.t) :: String.t
  def prepend(string_right, string_left) when is_bitstring(string_left) and is_bitstring(string_right) do
    string_left <> string_right
  end

  @doc """
  Prefixes `string` with `prefix`, only if `string` is non-empty.
  Otherwise it returns the original `string`.

  ## Examples

      # Prefix titles to names
      iex> "Armstrong" |> String.prefix("Mr. ")
      "Mr. Armstrong"

      iex> "" |> String.prefix("Mr. ")
      ""
      
      iex> "Armstrong" |> String.prefix("")
      "Armstrong"
      
      iex> "" |> String.prefix("")
      ""
  """
  @spec prefix(String.t, String.t) :: String.t
  def prefix(string, prefix)
  def prefix(string, "") when is_bitstring(string), do: string
  def prefix("", prefix) when is_bitstring(prefix), do: ""

  def prefix(string, prefix) when is_bitstring(string) and is_bitstring(prefix) do
    prefix <> string
  end

  @doc """
  Suffixes `string` with `suffix`, only if `string` is non-empty.
  Otherwise it returns the original `string`.

  ## Examples

      # Suffix line number to file name
      iex> "file.exs" |> String.suffix(":10")
      "file.exs:10"
      
      iex> "" |> String.suffix(":10")
      ""
      
      iex> "file.exs" |> String.suffix("")
      "file.exs"
      
      iex> "" |> String.suffix("")
      ""

  """
  @spec suffix(String.t, String.t) :: String.t
  def suffix(string, suffix)
  def suffix(string, "") when is_bitstring(string), do: string
  def suffix("", suffix) when is_bitstring(suffix), do: ""

  def suffix(string, suffix) when is_bitstring(string) and is_bitstring(suffix) do
    string <> suffix
  end

  @doc """
  Appends `joiner` & `string_right` to `string_left`, only if both strings are non-empty.
  Otherwise returns the non-empty string, with no `joiner`.

  ## Examples

      # Joining first names to last names
      iex> "Armstrong" |> String.join_append("Joe", ", ")
      "Armstrong, Joe"
      
      iex> "Armstrong" |> String.join_append("", ", ")
      "Armstrong"
      
      iex> "" |> String.join_append("Joe", ", ")
      "Joe"
      
      iex> String.join_append("", "", ", ")
      ""

      # Combining other functions
      iex> "Armstrong" |> String.join_append("Joe", ", ") |> String.suffix(".") |> String.prefix("- ")
      "- Armstrong, Joe."
      
      iex> "" |> String.join_append("Joe", ", ") |> String.suffix(".") |> String.prefix("- ")
      "- Joe."
      
      iex> "Armstrong" |> String.join_append("", ", ") |> String.suffix(".") |> String.prefix("- ")
      "- Armstrong."
      
      iex> "" |> String.join_append("", ", ") |> String.suffix(".") |> String.prefix("- ")
      ""

  """
  @spec join_append(String.t, String.t, String.t) :: String.t
  def join_append(string_left, string_right, joiner)

  def join_append("", "", _joiner), do: ""
  def join_append(string_left, "", _joiner) when is_bitstring(string_left), do: string_left
  def join_append("", string_right, _joiner) when is_bitstring(string_right), do: string_right
  
  def join_append(string_left, string_right, joiner) when is_bitstring(string_left) and is_bitstring(string_right) and is_bitstring(joiner) do
    string_left <> joiner <> string_right
  end

  @doc """
  Prepends `string_left` & `joiner` to `string_right`, only if both strings are non-empty.
  Otherwise returns the non-empty string, with no `joiner`.

  ## Examples

      # Prepend last names to first names
      iex> "Joe" |> String.join_prepend("Armstrong", ", ")
      "Armstrong, Joe"
      
      iex> "Joe" |> String.join_prepend("", ", ")
      "Joe"
      
      iex> "" |> String.join_prepend("Armstrong", ", ")
      "Armstrong"
      
      iex> String.join_prepend("", "", ",")
      ""

  """
  @spec join_prepend(String.t, String.t, String.t) :: String.t
  def join_prepend(string_right, string_left, joiner)

  def join_prepend("", "", _joiner), do: ""
  def join_prepend(string_right, "", _joiner) when is_bitstring(string_right), do: string_right
  def join_prepend("", string_left, _joiner) when is_bitstring(string_left), do: string_left
  
  def join_prepend(string_right, string_left, joiner) when is_bitstring(string_left) and is_bitstring(string_right) do
    string_left <> joiner <> string_right
  end

end