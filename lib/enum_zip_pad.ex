defmodule Experimental.EnumZipPad do
  require Logger
  
  @type t :: Enumerable.t

  @doc """
  Zips corresponding elements from two collections into one list
  of tuples.
  The one one collection is shorther than the other, it will be filled
  with either `padding1` or `padding2` (`nil` by default).
  ## Examples
      iex> Enum.zip_pad([1, 2], [:a, :b, :c], 0, :z)
      [{1, :a}, {2, :b}, {0, :c}]
      iex> Enum.zip_pad([1, 2, 3, 4, 5], [:a, :b, :c], 0, :z)
      [{1, :a}, {2, :b}, {3, :c}, {4, :z}, {5, :z}]
  """
  @spec zip_pad(t, t, any, any) :: [{any, any}]
  def zip_pad(collection1, collection2, padding1 \\ nil, padding2 \\ nil)

  def zip_pad([], [], _pad1, _pad2), do: []

  def zip_pad(col1, col2, pad1, pad2) when is_list(col1) and is_list(col2) do
    {h1, next1} = do_zip_pad_h_t(col1, pad1)
    {h2, next2} = do_zip_pad_h_t(col2, pad2)
    [{h1, h2}|zip_pad(next1, next2, pad1, pad2)]
  end

  defp do_zip_pad_h_t([], pad),        do: {pad, []}
  defp do_zip_pad_h_t([h|next], _pad), do: {h, next}
end